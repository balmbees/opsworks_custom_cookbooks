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
  Chef::Log.info("docker run #{dockerenvs} --name unicorn_rails -h #{node[:opsworks][:instance][:hostname]} -v /mnt/var/log/nginx:/var/log/nginx --network=host --pid=host --privileged --log-opt max-size=100m -d #{node[:docker][:DOCKER_RAILS_REPO]}")
  bash "docker-run" do
    user "root"
    cwd "#{deploy[:deploy_to]}"
    code <<-EOH
      if docker ps | grep unicorn_rails;
      then
        :
      else
        docker run #{dockerenvs} --name unicorn_rails -h #{node[:opsworks][:instance][:hostname]} -v /mnt/var/log/nginx:/var/log/nginx --network=host --pid=host --privileged --log-opt max-size=100m -d #{node[:docker][:DOCKER_RAILS_REPO]}
        sleep 3
      fi
    EOH
  end
end
