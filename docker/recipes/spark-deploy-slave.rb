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
      if docker ps -a | grep spark;
      then
        docker rm -f spark
        sleep 1
      fi
    EOH
  end

  dockerenvs = " "
  node[:custom_env][:spark].each do |key, value|
    dockerenvs=dockerenvs+" -e \"#{key}=#{value}\""
  end

  ##{node[:opsworks][:instance][:hostname].match(/\d+/).to_a.first.to_i} 
  Chef::Log.info("docker run --restart=always--net=host -e AWS_SECRET_ACCESS_KEY=#{node[:custom_env][:common][:AWS_SECRET_ACCESS_KEY]} -e AWS_ACCESS_KEY_ID=#{node[:custom_env][:common][:AWS_ACCESS_KEY_ID]} --name spark -e SPARK_MASTER_IP=#{node[:opsworks][:instance][:private_ip]} -e SPARK_LOCAL_HOSTNAME=#{node[:opsworks][:instance][:private_ip]} -e HOSTNAME=#{node[:opsworks][:instance][:private_ip]} -d vingle/spark 'cd /usr/local/spark/ ; sbin/start-slave.sh spark://#{node[:custom_env][:spark][:MASTER_IP]}:7077'")
  bash "docker-run" do
    user "root"
    cwd "#{deploy[:deploy_to]}"
    code <<-EOH
      if docker ps | grep spark;
      then
        :
      else
        docker pull vingle/spark
        docker run --restart=always--net=host -e AWS_SECRET_ACCESS_KEY=#{node[:custom_env][:common][:AWS_SECRET_ACCESS_KEY]} -e AWS_ACCESS_KEY_ID=#{node[:custom_env][:common][:AWS_ACCESS_KEY_ID]} --name spark -e SPARK_MASTER_IP=#{node[:opsworks][:instance][:private_ip]} -e SPARK_LOCAL_HOSTNAME=#{node[:opsworks][:instance][:private_ip]} -e HOSTNAME=#{node[:opsworks][:instance][:private_ip]} -d vingle/spark 'cd /usr/local/spark/ ; sbin/start-slave.sh spark://#{node[:custom_env][:spark][:MASTER_IP]}:7077'
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
