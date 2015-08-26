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
      docker pull #{deploy[:application]}/dockerfiles:newrelic
      docker pull #{deploy[:application]}/dockerfiles:td_agent2

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
  dockerenvs += " -e \"TD_AGENT_SERVER=#{node[:opsworks][:instance][:private_ip]}\""
  dockerenvs += " -e \"UNIX_TIMESTAMP=`date +%s`\""

  Chef::Log.info("docker run #{dockerenvs} --name td2 -d #{deploy[:application]}/dockerfiles:td_agent2")
  Chef::Log.info("docker run -e NEW_RELIC_LICENSE_KEY=#{node[:custom_env][:vingle][:NEWRELIC_KEY]} -h `hostname` -d #{deploy[:application]}/dockerfiles:newrelic")

  bash "docker-run" do
    user "root"
    cwd "#{deploy[:deploy_to]}"
    code <<-EOH
      if docker ps | grep td2;
      then
        :
      else
        docker run #{dockerenvs} --net=host --name td2 -d #{deploy[:application]}/dockerfiles:td_agent2
        sleep 3
      fi

      if docker ps | grep newrelic;
      then
        :
      else
        docker run -e NEW_RELIC_LICENSE_KEY=#{node[:custom_env][:vingle][:NEWRELIC_KEY]} -h `hostname` -d #{deploy[:application]}/dockerfiles:newrelic
        sleep 3
      fi
    EOH
  end
end
