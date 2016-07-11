Chef::Log.info("docker cleanup")
bash "docker-cleanup" do
  user "root"
  code <<-EOH
    docker pull #{deploy[:application]}/dockerfiles:newrelic
    docker pull #{deploy[:application]}/dockerfiles:logstash
    docker pull #{deploy[:application]}/dockerfiles:td_agent2

    if docker ps -a | grep logstash;
    then
      docker rm -f logstash
      sleep 1
    fi
    if docker ps -a | grep newrelic;
    then
      docker rm -f newrelic
      sleep 1
    fi
    if docker ps -a | grep td2;
    then
      docker rm -f td2
      sleep 1
    fi
  EOH
end

dockerenvs = " "
node[:custom_env][:vingle].each do |key, value|
  dockerenvs += " -e \"#{key}=#{value}\""
end

Chef::Log.info("docker run  --name logstash -e AWS_ACCESS_KEY_ID=#{node[:custom_env][:vingle][:AWS_ACCESS_KEY_ID]} -e AWS_SECRET_ACCESS_KEY=#{node[:custom_env][:vingle][:AWS_SECRET_ACCESS_KEY]} -e RAILS_ENV=#{node[:custom_env][:vingle][:RAILS_ENV]} -v /mnt/var/log/nginx:/var/log/nginx -d #{deploy[:application]}/dockerfiles:logstash")
Chef::Log.info("docker run -e NEW_RELIC_LICENSE_KEY=#{node[:custom_env][:vingle][:NEWRELIC_KEY]} -h `hostname` -d #{deploy[:application]}/dockerfiles:newrelic")
bash "docker-run" do
  user "root"
  cwd "#{deploy[:deploy_to]}"
  code <<-EOH
    if docker ps | grep td2;
    then
      :
    else
      docker run -d --name td2 #{dockerenvs} vingle/dockerfiles:td_agent2
      sleep 3
    fi
    if docker ps | grep newrelic;
    then
      :
    else
      docker run -e NEW_RELIC_LICENSE_KEY=#{node[:custom_env][:vingle][:NEWRELIC_KEY]} -h `hostname` -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v /var/run/docker.sock:/var/run/docker.sock -d #{deploy[:application]}/dockerfiles:newrelic
      sleep 3
    fi

    if docker ps | grep logstash;
    then
      :
    else
      docker run --name logstash -e AWS_ACCESS_KEY_ID=#{node[:custom_env][:vingle][:AWS_ACCESS_KEY_ID]} -e AWS_SECRET_ACCESS_KEY=#{node[:custom_env][:vingle][:AWS_SECRET_ACCESS_KEY]} -e RAILS_ENV=#{node[:custom_env][:vingle][:RAILS_ENV]} -v /mnt/var/log/nginx:/var/log/nginx -d #{deploy[:application]}/dockerfiles:logstash
      sleep 3
    fi
  EOH
end
