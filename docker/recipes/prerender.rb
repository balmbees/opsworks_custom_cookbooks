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
      #   docker rmi #{deploy[:application]}/#{node[:custom_env][:vingle][:RAILS_ENV]}
      # fi
      if docker ps -a | grep prerender;
      then
        docker rm prerender
        sleep 1
      fi
    EOH
  end

  dockerenvs = " "
  node[:custom_env][:vingle].each do |key, value|
    dockerenvs=dockerenvs+" -e \"#{key}=#{value}\""
  end

  Chef::Log.info("docker run #{dockerenvs} --name prerender -p 3000:3000 -d #{deploy[:application]}/prerender")
  bash "docker-run" do
    user "root"
    cwd "#{deploy[:deploy_to]}"
    code <<-EOH
      if docker ps | grep prerender;
      then
        :
      else
        docker pull #{deploy[:application]}/prerender
        docker run #{dockerenvs} --name prerender -p 3000:3000 -d #{deploy[:application]}/prerender
      fi
    EOH
  end
end
