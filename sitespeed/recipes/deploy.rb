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

  Chef::Log.info("docker login")
  bash "docker login" do
    user "root"
    cwd "#{deploy[:deploy_to]}"
    code <<-EOH
      docker login -e #{node[:docker][:DOCKER_EMAIL]} -u #{node[:docker][:DOCKER_USERNAME]} -p #{node[:docker][:DOCKER_PASSWORD]}
    EOH
  end

  Chef::Log.info("docker cleanup")
  bash "docker-cleanup" do
    user "root"
    code <<-EOH
      if docker ps | grep sitespeed;
      then
        docker stop sitespeed
        sleep 3
      fi
      if docker ps -a | grep sitespeed;
      then
        docker rm sitespeed
        sleep 1
      fi
    EOH
  end

  docker_envs = " "
  node[:sitespeed][:env].each do |key, value|
    docker_envs += " -e \"#{key}=#{value}\""
  end
  docker_envs += " -e \"REGION=#{node[:opsworks][:instance][:hostname]}\""

  Chef::Log.info("docker run #{docker_envs} --name sitespeed -d #{node[:sitespeed][:DOCKER_REPO]}")
  bash "docker-pull" do
    user "root"
    cwd "#{deploy[:deploy_to]}"
    code <<-EOH
      if docker ps | grep sitespeed;
      then
        :
      else
        docker pull #{node[:sitespeed][:DOCKER_REPO]}
        sleep 3
      fi
    EOH
  end

  template "/etc/crontab" do
    mode "0644"
    source "crontab.erb"
    variables docker_envs: docker_envs, docker_repo: node[:sitespeed][:DOCKER_REPO]
  end
end
