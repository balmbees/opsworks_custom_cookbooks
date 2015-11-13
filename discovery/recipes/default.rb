include_recipe 'cron'

code = <<-CODE
curl --silent -X put -d '{ "Datacenter": "dc1", "Node": "#{node[:opsworks][:instance][:hostname]}", "Address": "#{node[:opsworks][:instance][:private_ip]}" }' http://107.21.109.230:8500/v1/catalog/register 2&1> /dev/null
CODE

cron_d "discovery-service" do
  command code
  user "root"
  path "/usr/local/bin"
end
