Chef::Log.info("docker login")
bash "docker login" do
  user "root"
  code <<-EOH
    docker login -u #{node[:custom_env][:vingle][:DOCKER_USERNAME]} -p #{node[:custom_env][:vingle][:DOCKER_PASSWORD]}
  EOH
end
