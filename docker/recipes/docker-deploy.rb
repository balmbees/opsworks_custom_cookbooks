include_recipe 'deploy'

node[:deploy].each do |application, deploy|
  # if node[:opsworks][:instance][:layers].first != deploy[:environment_variables][:layer]
  #   Chef::Log.debug("Skipping deploy::docker application #{application} as it is not deployed to this layer")
  #   next
  # end

  opsworks_deploy_dir do
    user deploy[:user]
    group deploy[:group]
    path deploy[:deploy_to]
  end

  opsworks_deploy do
    deploy_data deploy
    app application
  end

  Chef::Log.info("docker login")
  bash "docker login" do
    user "root"
    cwd "#{deploy[:deploy_to]}"
    code <<-EOH
      docker login -e #{node[:custom_env][:vingle][:DOCKER_EMAIL]} -u #{node[:custom_env][:vingle][:DOCKER_USERNAME]} -p #{node[:custom_env][:vingle][:DOCKER_PASSWORD]}
    EOH
  end

  Chef::Log.info("docker cleanup")
  bash "docker-cleanup" do
    user "root"
    code <<-EOH
      docker pull #{node[:docker][:DOCKER_RAILS_REPO]}
      docker pull #{deploy[:application]}/dockerfiles:newrelic
      docker pull #{deploy[:application]}/dockerfiles:logstash

      if docker ps -a | grep unicorn_rails;
      then
        docker rm -f unicorn_rails
        sleep 1
      fi
      if docker ps -a | grep logstash;
      then
        docker rm -f logstash
        sleep 1
      fi

      if docker ps -a | grep td;
      then
        docker rm -f td
        sleep 1
      fi
    EOH
  end

  dockerenvs = " "
  node[:custom_env][:vingle].each do |key, value|
    dockerenvs += " -e \"#{key}=#{value}\""
  end
  dockerenvs += " -e \"TD_AGENT_SERVER=#{node[:opsworks][:instance][:private_ip]}\""
  dockerenvs += " -e \"UNIX_TIMESTAMP=`date +%s`\""

  Chef::Log.info("docker run #{dockerenvs} --name td -d #{deploy[:application]}/dockerfiles:td_agent2")
  Chef::Log.info("docker run -v /mnt/var/log/nginx:/var/log/nginx -d #{deploy[:application]}/dockerfiles:logstash")
  Chef::Log.info("docker run -e NEW_RELIC_LICENSE_KEY=#{node[:custom_env][:vingle][:NEWRELIC_KEY]} -h `hostname` -d #{deploy[:application]}/dockerfiles:newrelic")
  Chef::Log.info("docker run #{dockerenvs} --name unicorn_rails -h #{node[:opsworks][:instance][:hostname]} -v /mnt/var/log/nginx:/var/log/nginx -p 80:80 -p 8080:8080 -d #{node[:docker][:DOCKER_RAILS_REPO]}")
  bash "docker-run" do
    user "root"
    cwd "#{deploy[:deploy_to]}"
    code <<-EOH
      if docker ps | grep td;
      then
        :
      else
        docker pull #{deploy[:application]}/dockerfiles:td_agent2
        docker run --net=host #{dockerenvs} --name td -d #{deploy[:application]}/dockerfiles:td_agent2
        sleep 3
      fi

      if docker ps | grep unicorn_rails;
      then
        :
      else
        docker run #{dockerenvs} --name unicorn_rails -h #{node[:opsworks][:instance][:hostname]} -v /mnt/var/log/nginx:/var/log/nginx -p 80:80 -p 8080:8080 -d #{node[:docker][:DOCKER_RAILS_REPO]}
        sleep 3
      fi

      if docker ps | grep newrelic;
      then
        :
      else
        docker run -e NEW_RELIC_LICENSE_KEY=#{node[:custom_env][:vingle][:NEWRELIC_KEY]} -h `hostname` -d #{deploy[:application]}/dockerfiles:newrelic
        sleep 3
      fi

      if docker ps | grep logstash;
      then
        :
      else
        docker run --name logstash -v /mnt/var/log/nginx:/var/log/nginx -d #{deploy[:application]}/dockerfiles:logstash
      fi
    EOH
  end
end
