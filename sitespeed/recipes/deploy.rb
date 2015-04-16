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

  docker_envs = " "
  node[:sitespeed][:env].each do |key, value|
    docker_envs += " -e \"#{key}=#{value}\""
  end
  docker_envs += " -e \"REGION=#{node[:opsworks][:instance][:hostname]}\""

  Chef::Log.info("docker run #{docker_envs} #{node[:sitespeed][:DOCKER_REPO]}")
  bash "docker-pull" do
    user "root"
    cwd "#{deploy[:deploy_to]}"
    code <<-EOH
      docker pull #{node[:sitespeed][:DOCKER_REPO]}
      sleep 3
    EOH
  end

  template "/etc/crontab.conf" do
    mode "0644"
    source "crontab.conf.erb"
    variables docker_envs: docker_envs, docker_repo: node[:sitespeed][:DOCKER_REPO]
  end

  execute "setup crontab" do
    command "crontab /etc/crontab.conf"
  end
end
