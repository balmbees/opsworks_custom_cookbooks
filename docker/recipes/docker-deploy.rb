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

  Chef::Log.info('docker cleanup dangling')
  bash 'docker-cleanup-dangling' do
    user "root"
    code <<-EOH
      docker rm -v `docker ps -a -q -f status=exited` || true # Delete stopped containers
      docker rmi $(docker images -q -f dangling=true) || true # Delete dangling images
      docker volume rm $(docker volume ls -q -f dangling=true) || true # Delete dangling volumes
    EOH
  end

  Chef::Log.info("docker cleanup")
  bash "docker-cleanup" do
    user "root"
    code <<-EOH
      docker pull #{node[:docker][:DOCKER_RAILS_REPO]}
      docker pull #{deploy[:application]}/dockerfiles:newrelic
      docker pull #{deploy[:application]}/dockerfiles:logstash
      docker pull #{deploy[:application]}/dockerfiles:td_agent2

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
  dockerenvs += " -e \"TD_AGENT_SERVER=td2\""
  dockerenvs += " -e \"UNIX_TIMESTAMP=`date +%s`\""

  dns = node[:custom_env][:vingle][:DNS_IP] || "107.21.109.230"

  Chef::Log.info("docker run -d -p 53:53/tcp -p 53:53/udp --cap-add=NET_ADMIN --name dnsmasq andyshinn/dnsmasq -S /node.consul/#{dns}")
  Chef::Log.info("docker run  --name logstash -e AWS_ACCESS_KEY_ID=#{node[:custom_env][:vingle][:AWS_ACCESS_KEY_ID]} -e AWS_SECRET_ACCESS_KEY=#{node[:custom_env][:vingle][:AWS_SECRET_ACCESS_KEY]} -e RAILS_ENV=#{node[:custom_env][:vingle][:RAILS_ENV]} -v /mnt/var/log/nginx:/var/log/nginx -d #{deploy[:application]}/dockerfiles:logstash")
  Chef::Log.info("docker run -e NEW_RELIC_LICENSE_KEY=#{node[:custom_env][:vingle][:NEWRELIC_KEY]} -h `hostname` -d #{deploy[:application]}/dockerfiles:newrelic")
  Chef::Log.info("docker run#{dockerenvs} --name unicorn_rails -h #{node[:opsworks][:instance][:hostname]} -v /mnt/var/log/nginx:/var/log/nginx -p 80:80 -p 8080:8080 -d #{node[:docker][:DOCKER_RAILS_REPO]}")
  bash "docker-run" do
    user "root"
    cwd "#{deploy[:deploy_to]}"
    code <<-EOH
      if docker ps | grep dnsmasq;
      then
        :
      else
        docker run -d -p 53:53/tcp -p 53:53/udp --cap-add=NET_ADMIN --name dnsmasq andyshinn/dnsmasq -S /node.consul/#{dns}
        sleep 3
      fi

      if docker ps | grep td2;
      then
        :
      else
        docker run -d --name td2 #{dockerenvs} vingle/dockerfiles:td_agent2
        sleep 3
      fi

      if docker ps | grep unicorn_rails;
      then
        :
      else
        docker run --link td2:td2 --dns=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' dnsmasq) #{dockerenvs} --name unicorn_rails -h #{node[:opsworks][:instance][:hostname]} -v /mnt/var/log/nginx:/var/log/nginx -p 80:80 -p 8080:8080 -d #{node[:docker][:DOCKER_RAILS_REPO]}
        sleep 3
      fi

      if docker ps | grep newrelic;
      then
        :
      else
        docker run -e NEW_RELIC_LICENSE_KEY=#{node[:custom_env][:vingle][:NEWRELIC_KEY]} -h `hostname` -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v /var/run/docker.sock:/var/run/docker.sock -d #{deploy[:application]}/dockerfiles:newrelic
        sleep 3
      fi

      if docker ps | grep logstash;
      then
        :
      else
        docker run --name logstash -e AWS_ACCESS_KEY_ID=#{node[:custom_env][:vingle][:AWS_ACCESS_KEY_ID]} -e AWS_SECRET_ACCESS_KEY=#{node[:custom_env][:vingle][:AWS_SECRET_ACCESS_KEY]} -e RAILS_ENV=#{node[:custom_env][:vingle][:RAILS_ENV]} -v /mnt/var/log/nginx:/var/log/nginx -d #{deploy[:application]}/dockerfiles:logstash
        sleep 3
      fi
    EOH
  end
end
