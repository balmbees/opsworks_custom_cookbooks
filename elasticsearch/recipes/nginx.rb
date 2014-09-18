execute 'apt-get update' do
  command 'apt-get update'
  action :run
end

package 'nginx' do
 action :install
end

template '/etc/nginx/conf.d/kibana.conf' do
  source 'nginx-kibana.conf.erb'
  owner 'root'
  group 'root'
  mode '0644'
end

template '/etc/nginx/nginx.conf' do
  source 'nginx.conf.erb'
  owner 'root'
  group 'root'
  mode '0644'
end

service 'nginx' do
  supports :status => true
  action [ :enable, :restart ]
end
