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
      # if docker ps -a | grep #{deploy[:application]};
      # then
      #   docker stop #{deploy[:application]}
      #   sleep 3
      #   docker rm #{deploy[:application]}
      #   sleep 3
      # fi
      # if docker images | grep #{deploy[:application]};
      # then
      #   docker rmi #{deploy[:application]}/balmbees:#{node[:custom_env][:vingle][:RAILS_ENV]}
      # fi
      if docker ps -a | grep unicorn_rails;
      then
        docker rm unicorn_rails
        sleep 1
      fi
      if docker ps -a | grep td;
      then
        docker rm td
        sleep 1
      fi
    EOH
  end

  Chef::Log.info("docker pull images")
  bash "docker pull images" do
    user "root"
    cwd "#{deploy[:deploy_to]}"
    code <<-EOH
      # if docker ps -a | grep td_agent;
      # then
      #   :
      # else
      #   docker pull #{deploy[:application]}/dockerfiles:td_agent
      # fi
      # if docker ps -a | grep logstash;
      # then
      #   :
      # else
      #   docker pull #{deploy[:application]}/dockerfiles:logstash
      # fi
      # docker pull #{deploy[:application]}/dockerfiles:td_agent
      # docker pull #{deploy[:application]}/dockerfiles:logstash
      # docker pull #{deploy[:application]}/balmbees:#{node[:custom_env][:vingle][:RAILS_ENV]}
    EOH
  end

  dockerenvs = " "
  node[:custom_env][:vingle].each do |key, value|
    dockerenvs=dockerenvs+" -e \"#{key}=#{value}\""
  end

  Chef::Log.info("docker run #{dockerenvs} --name td -d #{deploy[:application]}/dockerfiles:td_agent")
  Chef::Log.info("docker run -v /mnt/var/log/nginx:/var/log/nginx -d #{deploy[:application]}/dockerfiles:logstash")
  Chef::Log.info("docker run #{dockerenvs} --name unicorn_rails -h #{node[:opsworks][:instance][:hostname]} -v /mnt/var/log/nginx:/var/log/nginx -p 80:80 -p 8080:8080 --link td:td -d #{deploy[:application]}/balmbees:#{node[:custom_env][:vingle][:RAILS_ENV]}")
  bash "docker-run" do
    user "root"
    cwd "#{deploy[:deploy_to]}"
    code <<-EOH
      # if docker ps | grep td_agent;
      # then
      #   :
      # else
      #   docker run #{dockerenvs} --name td -d #{deploy[:application]}/dockerfiles:td_agent
      # fi
      # if docker ps | grep logstash;
      # then
      #   :
      # else
      #   sleep 3
      #   docker run -v /mnt/var/log/nginx:/var/log/nginx -d #{deploy[:application]}/dockerfiles:logstash
      # fi
      docker pull #{deploy[:application]}/dockerfiles:logstash
      docker run -v /mnt/var/log/nginx:/var/log/nginx -d #{deploy[:application]}/dockerfiles:logstash

      docker pull #{deploy[:application]}/dockerfiles:td_agent
      docker run #{dockerenvs} --name td -d #{deploy[:application]}/dockerfiles:td_agent

      docker pull #{deploy[:application]}/balmbees:#{node[:custom_env][:vingle][:RAILS_ENV]}
      docker run #{dockerenvs} --name unicorn_rails -h #{node[:opsworks][:instance][:hostname]} -v /mnt/var/log/nginx:/var/log/nginx -p 80:80 -p 8080:8080 --link td:td -d #{deploy[:application]}/balmbees:#{node[:custom_env][:vingle][:RAILS_ENV]}
    EOH
  end
end
