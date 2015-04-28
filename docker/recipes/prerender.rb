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
      docker login -e #{node[:custom_env][:prerender][:DOCKER_EMAIL]} -u #{node[:custom_env][:prerender][:DOCKER_USERNAME]} -p #{node[:custom_env][:prerender][:DOCKER_PASSWORD]}
    EOH
  end

  Chef::Log.info("docker cleanup")
  bash "docker-cleanup" do
    user "root"
    code <<-EOH
      if docker ps -a | grep prerender;
      then
        docker rm -f prerender
        sleep 1
      fi
    EOH
  end

  dockerenvs = " "
  node[:custom_env][:prerender].each do |key, value|
    dockerenvs=dockerenvs+" -e \"#{key}=#{value}\""
  end

  Chef::Log.info("docker run --restart=always #{dockerenvs} --name prerender -p 3000:3000 -d vingle/prerender")
  bash "docker-run" do
    user "root"
    cwd "#{deploy[:deploy_to]}"
    code <<-EOH
      if docker ps | grep prerender;
      then
        :
      else
        docker pull vingle/prerender
        docker run --restart=always #{dockerenvs} --name prerender -p 3000:3000 -d vingle/prerender
      fi

      if docker ps | grep newrelic;
      then
        :
      else
        docker pull vingle/dockerfiles:newrelic
        docker run -e NEW_RELIC_LICENSE_KEY=#{node[:custom_env][:prerender][:NEWRELIC_KEY]} -h `hostname` -d vingle/dockerfiles:newrelic
        sleep 3
      fi
    EOH
  end
end
