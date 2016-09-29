service "ecs" do
  action :stop

  provider Chef::Provider::Service::Upstart

  only_if { platform?("amazon") }
end

execute "Stop all containers" do
  command "docker stop --time=30 $(docker ps -a -q)"

  only_if do
    ::File.exist?("/usr/bin/docker") && OpsWorks::ShellOut.shellout("docker ps -a")
  end
end

execute "Remove all containers" do
  command "docker rm $(docker ps -a -q)"

  only_if do
    ::File.exist?("/usr/bin/docker") && OpsWorks::ShellOut.shellout("docker ps -a")
  end
end
