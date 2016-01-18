
execute 'Download newrelic' do
  command ['/usr/bin/docker',
           'pull',
           'newrelic/nrsysmond:latest'].join(' ')
  only_if do
    ::File.exist?('/usr/bin/docker')
  end
end

execute 'Run newrelic' do
  command ['/usr/bin/docker',
           'run',
           '--name nrsysmond',
           '--privileged=true',
           '--pid=host',
           '--net=host',
           '-d',
           '-v /sys:/sys',
           '-v /dev:/dev',
           '-v /var/run/docker.sock:/var/run/docker.sock',
           '-v /var/log:/var/log:rw',
           "-e NRSYSMOND_license_key=#{node[:custom_env][:vingle][:NEWRELIC_KEY]}",
           '-e NRSYSMOND_logfile=/var/log/nrsysmond.log',
           'newrelic/nrsysmond:latest'].join(' ')
  only_if do
    ::File.exist?('/usr/bin/docker') && !OpsWorks::ShellOut.shellout('docker ps -a').include?('nrsysmond')
  end
end

execute 'Login dockerhub' do
  command ['/usr/bin/docker',
           'login',
           "-e #{node[:custom_env][:vingle][:DOCKER_EMAIL]}",
           "-u #{node[:custom_env][:vingle][:DOCKER_USERNAME]}",
           "-p #{node[:custom_env][:vingle][:DOCKER_PASSWORD]}",
           '"https://index.docker.io/v1/"'].join(' ')

end

bash "Login dockerhub ecs" do
  user "root"
  code <<-EOH
    echo 'ECS_ENGINE_AUTH_TYPE=docker' >> /etc/ecs/ecs.config
    echo 'ECS_ENGINE_AUTH_DATA={"https://index.docker.io/v1/":{"username":"#{node[:custom_env][:vingle][:DOCKER_USERNAME]}","password":"#{node[:custom_env][:vingle][:DOCKER_PASSWORD]}","email":"#{node[:custom_env][:vingle][:DOCKER_EMAIL]}"}}' >> /etc/ecs/ecs.config
  EOH
end
