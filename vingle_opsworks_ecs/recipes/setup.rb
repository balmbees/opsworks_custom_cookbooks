directory "/etc/ecs" do
  action :create
  owner "root"
  mode 0755
end

template "ecs.config" do
  path "/etc/ecs/ecs.config"
  source "ecs.config.erb"
  owner "root"
  group "root"
  mode 0644
end

directory "/var/lib/ecs/data" do
  action :create
  owner "root"
  mode 0755
  recursive true
end

directory "/var/log/ecs" do
  action :create
  owner "root"
  mode 0755
end

group "docker" do
  action :create
end

if platform?(*node["vingle_opsworks_ecs"]["supported_platforms"])
  include_recipe "vingle_opsworks_ecs::setup_#{node["platform"]}"
else
  Chef::Application.fatal!("The platform #{node["platform"]} is not support by OpsWorks.")
end

execute 'Login dockerhub' do
  command ['/usr/bin/docker',
           'login',
           "-e #{node[:custom_env][:vingle][:DOCKER_EMAIL]}",
           "-u #{node[:custom_env][:vingle][:DOCKER_USERNAME]}",
           "-p #{node[:custom_env][:vingle][:DOCKER_PASSWORD]}",
           '"https://index.docker.io/v1/"'].join(' ')

end

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

execute "Clean up previous ECS agent container" do
  command ["/usr/bin/docker",
           "rm",
           "-f",
           "ecs-agent"].join(" ")

  only_if do
    ::File.exist?("/usr/bin/docker") && !OpsWorks::ShellOut.shellout("docker ps -a").include?("amazon-ecs-agent")
  end
end

execute "Update AWS ECS agent to latest version" do
  command ["/usr/bin/docker",
           "pull",
           "amazon/amazon-ecs-agent:latest"].join(" ")

  only_if do
    ::File.exist?("/usr/bin/docker")
  end
end

execute "Install the Amazon ECS agent" do
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

    Chef::Application.fatal!("ECS agent is registered to a different cluster.") unless ecs_agent.cluster == node["vingle_opsworks_ecs"]["ecs_cluster_name"]
  end
end
