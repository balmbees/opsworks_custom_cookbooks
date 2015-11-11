bash "discovery service" do
  user "root"
  code "nohup bash -c 'until [ -f 1 ]; do sleep 60; curl -X put -d \"{ \\'Datacenter\\': \\'dc1\\', \\'Node\\': \\'#{node[:opsworks][:instance][:hostname]}\\', \\\'Address\\': \\'#{node[:opsworks][:instance][:private_ip]}\\' }\" http://107.21.109.230:8500/v1/catalog/register > /dev/null; done' &"
end
