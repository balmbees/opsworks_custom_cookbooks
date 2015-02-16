include_recipe 'deploy'

node[:deploy].each do |application, deploy|
  if node[:opsworks][:instance][:layers].first != deploy[:environment_variables][:layer]
    Chef::Log.debug("Skipping deploy::docker application #{application} as it is not deployed to this layer")
    next
  end

  opsworks_deploy_dir do
    user deploy[:user]
    group deploy[:group]
    path deploy[:deploy_to]
  end

  opsworks_deploy do
    deploy_data deploy
    app application
  end

  bash "docker-cleanup" do
    user "root"
    code <<-EOH
      if docker ps | grep #{deploy[:application]}; 
      then
        docker stop #{deploy[:application]}
        sleep 3
        docker rm #{deploy[:application]}
        sleep 3
      fi
      if docker images | grep #{deploy[:application]}; 
      then
        docker rmi #{deploy[:application]}
      fi
    EOH
  end

  # bash "docker-build" do
  #   user "root"
  #   cwd "#{deploy[:deploy_to]}/current"
  #   code <<-EOH
  #    docker build -t=#{deploy[:application]} . > #{deploy[:application]}-docker.out
  #   EOH
  # end

  Chef::Log.info "docker login"
  Chef::Log.info "docker login -e #{deploy[:environment_variables][:docker_email]} -u #{deploy[:environment_variables][:docker_username]} -p #{deploy[:environment_variables][:docker_password]}"
  bash "docker login" do
    user "root"
    cwd "#{deploy[:deploy_to]}/current"
    code <<-EOH
      docker login -e #{deploy[:environment_variables][:docker_email]} -u #{deploy[:environment_variables][:docker_username]} -p #{deploy[:environment_variables][:docker_password]}
    EOH
  end

  Chef::Log.info "docker pull images"
  Chef::Log.info "docker pull #{deploy[:application]}/balmbees"
  bash "docker pull images" do
    user "root"
    cwd "#{deploy[:deploy_to]}/current"
    code <<-EOH
      docker pull #{deploy[:application]}/balmbees
    EOH
  end

  dockerenvs = " "
  deploy[:environment_variables].each do |key, value|
    # dockerenvs=dockerenvs+" -e "+key+"="+value
    dockerenvs=dockerenvs+" -e \"#{key}=#{value}\""
  end

  Chef::Log.info "docker run"
  Chef::Log.info "docker run #{dockerenvs} -p #{deploy[:environment_variables][:service_port]}:#{deploy[:environment_variables][:container_port]} -p 8080:8080 --name #{deploy[:application]} -d #{deploy[:application]}/balmbees"
  bash "docker-run" do
    user "root"
    cwd "#{deploy[:deploy_to]}/current"
    code <<-EOH
      docker run #{dockerenvs} -p #{deploy[:environment_variables][:service_port]}:#{deploy[:environment_variables][:container_port]} -p 8080:8080 --name #{deploy[:application]} -d #{deploy[:application]}/balmbees
    EOH
  end
end
