
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

execute "Stop exsiting the Amazon ECS agent" do
  command ["/usr/bin/docker",
           "rm",
           "-f",
           "ecs-agent"].join(" ")

  only_if do
    ::File.exist?("/usr/bin/docker") && OpsWorks::ShellOut.shellout("docker ps -a").include?("amazon-ecs-agent")
  end
end

execute "Start the Amazon ECS agent" do
  command ["/usr/bin/docker",
           "run",
           "--name ecs-agent",
           "-d",
           "-v /var/run/docker.sock:/var/run/docker.sock",
           "-v /var/log/ecs:/log",
           "-v /var/lib/ecs/data:/data",
           "-p 127.0.0.1:51678:51678",
           "--env-file /etc/ecs/ecs.config",
           "amazon/amazon-ecs-agent:latest"].join(" ")

  only_if do
    ::File.exist?("/usr/bin/docker") && !OpsWorks::ShellOut.shellout("docker ps -a").include?("amazon-ecs-agent")
  end
end

ruby_block "Check that the ECS agent is running" do
  block do
    ecs_agent = OpsWorks::ECSAgent.new

    Chef::Application.fatal!("ECS agent could not start.") unless ecs_agent.wait_for_availability
  end
end
