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
      docker login -e #{node[:custom_env][:common][:DOCKER_EMAIL]} -u #{node[:custom_env][:common][:DOCKER_USERNAME]} -p #{node[:custom_env][:common][:DOCKER_PASSWORD]}
    EOH
  end

  Chef::Log.info("docker cleanup")
  bash "docker-cleanup" do
    user "root"
    code <<-EOH
      if docker ps -a | grep kafka;
      then
        docker rm -f kafka
        sleep 1
      fi
    EOH
  end

  dockerenvs = " "
  node[:custom_env][:kafka].each do |key, value|
    dockerenvs=dockerenvs+" -e \"#{key}=#{value}\""
  end

  Chef::Log.info("docker run --restart=always #{dockerenvs} --name kafka -p 2181:2181 -p 9092:9092 -e ADVERTISED_HOST=#{node[:opsworks][:instance][:private_ip]} -e ADVERTISED_PORT=9092 -d vingle/kafka")
  bash "docker-run" do
    user "root"
    cwd "#{deploy[:deploy_to]}"
    code <<-EOH
      if docker ps | grep kafka;
      then
        :
      else
        docker pull vingle/kafka
        docker run --restart=always #{dockerenvs} --name kafka -p 2181:2181 -p 9092:9092 -e ADVERTISED_HOST=#{node[:opsworks][:instance][:private_ip]} -e ADVERTISED_PORT=9092 -d vingle/kafka
      fi

      if docker ps | grep newrelic;
      then
        :
      else
        docker pull vingle/dockerfiles:newrelic
        docker run -e NEW_RELIC_LICENSE_KEY=#{node[:custom_env][:common][:NEWRELIC_KEY]} -h `hostname` -d vingle/dockerfiles:newrelic
        sleep 3
      fi
    EOH
  end
end
