include_recipe 'deploy'

node[:deploy].each do |application, deploy|

  opsworks_deploy_dir do
    user deploy[:user]
    group deploy[:group]
    path deploy[:deploy_to]
  end

  opsworks_deploy do
    deploy_data deploy
    app application
  end

  Chef::Log.info("Tweak Kernel parameters")
  bash "tweak-kernal-params" do
    user "root"
    code <<-EOH
      echo 'Backup previous sysctl configurations to sysctl-backup.list...'
      sysctl -a | tee sysctl-backup`date +"%Y-%m-%d_%H-%M-%S"`.list
      
      printf '\n\n\n...\n\n\n\n\n'
      
      # Turn on TCP window scaling
      printf '\n\n====> Turn on TCP window scaling feature...\n'
      sysctl -w net.ipv4.tcp_window_scaling="1"
      
      # Increase TCP socket buffer size
      printf '\n\n====> Increasing TCP socket buffer size...\n'
      sysctl -w net.core.rmem_default="253952"
      sysctl -w net.core.wmem_default="253952"
      sysctl -w net.core.rmem_max="16777216"
      sysctl -w net.core.wmem_max="16777216"
      sysctl -w net.ipv4.tcp_rmem="253952 253952 16777216"
      sysctl -w net.ipv4.tcp_wmem="253952 253952 16777216"
      
      # Increase inbound backlog queue length
      printf '\n\n====> Increasing inbound backlog queue length...\n'
      sysctl -w net.core.netdev_max_backlog="30000"
      
      # Increase outbound backlog queue length
      printf '\n\n====> Increasing outbound backlog queue length...\n'
      ulimit -Hn 65535
      ulimit -Sn 65535
      sysctl -w net.core.somaxconn="1024"
      sysctl -w net.ipv4.tcp_max_syn_backlog="1024"
      
      # Increase local port range
      printf '\n\n====> Increasing local port range....\n'
      sysctl -w net.ipv4.ip_local_port_range="10240 65535"
      
      # Increase TIME_WAIT state socket buckets
      printf '\n\n====> Increasing TIME_WAIT state socket buckets...\n'
      sysctl -w net.ipv4.tcp_max_tw_buckets="1800000"
      
      # Turn on TIME_WAIT state socket re-use ability
      printf '\n\n====> Turn on TIME_WAIT state socket re-use ability...\n'
      sysctl -w net.ipv4.tcp_timestamps="1"
      sysctl -w net.ipv4.tcp_tw_reuse="1"
      
      printf '\n\n==========> Done.\n'
    EOH
  end

  Chef::Log.info("docker cleanup")
  bash "docker-cleanup" do
    user "root"
    code <<-EOH
      docker pull #{node[:docker][:DOCKER_RAILS_REPO]}

      if docker ps -a | grep unicorn_rails;
      then
        docker rm -f unicorn_rails
        sleep 1
      fi
    EOH
  end

  dockerenvs = " "
  node[:custom_env][:vingle].each do |key, value|
    dockerenvs += " -e \"#{key}=#{value}\""
  end
  dockerenvs += " -e \"TD_AGENT_SERVER=td2\""
  dockerenvs += " -e \"UNIX_TIMESTAMP=`date +%s`\""

  Chef::Log.info("docker run  --name logstash -e AWS_ACCESS_KEY_ID=#{node[:custom_env][:vingle][:AWS_ACCESS_KEY_ID]} -e AWS_SECRET_ACCESS_KEY=#{node[:custom_env][:vingle][:AWS_SECRET_ACCESS_KEY]} -e RAILS_ENV=#{node[:custom_env][:vingle][:RAILS_ENV]} -v /mnt/var/log/nginx:/var/log/nginx -d #{deploy[:application]}/dockerfiles:logstash")
  Chef::Log.info("docker run -e NEW_RELIC_LICENSE_KEY=#{node[:custom_env][:vingle][:NEWRELIC_KEY]} -h `hostname` -d #{deploy[:application]}/dockerfiles:newrelic")
  Chef::Log.info("docker run#{dockerenvs} --name unicorn_rails -h #{node[:opsworks][:instance][:hostname]} -v /mnt/var/log/nginx:/var/log/nginx --network=host --pid=host --privileged -d #{node[:docker][:DOCKER_RAILS_REPO]}")
  bash "docker-run" do
    user "root"
    cwd "#{deploy[:deploy_to]}"
    code <<-EOH
      if docker ps | grep unicorn_rails;
      then
        :
      else
        docker run --link td2:td2 #{dockerenvs} --name unicorn_rails -h #{node[:opsworks][:instance][:hostname]} -v /mnt/var/log/nginx:/var/log/nginx --network=host --pid=host --privileged -d #{node[:docker][:DOCKER_RAILS_REPO]}
        sleep 3
      fi
    EOH
  end
end
