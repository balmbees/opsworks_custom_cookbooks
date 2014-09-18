
filename = node[:elasticsearch][:deb_url].split('/').last
remote_file "/tmp/#{filename}" do
  source node[:elasticsearch][:deb_url]
  checksum node[:elasticsearch][:deb_sha]
  mode 0755
end

dpkg_package "/tmp/#{filename}" do
  action :install
end

directory '/data' do
  owner 'elasticsearch'
  group 'elasticsearch'
  mode '0755'
  recursive true
  action :create
end

template '/etc/elasticsearch/elasticsearch.yml' do
  source 'elasticsearch.yml.erb'
  owner 'elasticsearch'
  group 'elasticsearch'
  mode '0644'
end

service 'elasticsearch' do
  supports :status => true
  action [ :enable, :start ]
end
