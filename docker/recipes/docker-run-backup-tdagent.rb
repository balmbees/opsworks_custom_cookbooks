Chef::Log.info("docker run tdagent (backup)")
bash "docker-pull-tdagent" do
  user "root"
  code <<-EOH
    docker pull vingle/dockerfiles:td_agent2

    if docker ps -a | grep td2-backup;
    then
      docker rm -f td2-backup
      sleep 1
    fi
  EOH
end

dockerenvs = " "
node[:custom_env][:vingle].each do |key, value|
  dockerenvs += " -e \"#{key}=#{value}\""
end

Chef::Log.info("docker run -d --name td2-backup -p 127.0.0.1:24224:24224 #{dockerenvs} vingle/dockerfiles:td_agent2")
bash "docker-run-backup-tdagent" do
  user "root"
  code <<-EOH
    if docker ps | grep td2-backup;
    then
      :
    else
      docker run -d --name td2-backup -p 127.0.0.1:24224:24224 #{dockerenvs} vingle/dockerfiles:td_agent2
      sleep 3
    fi
  EOH
end
