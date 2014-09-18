directory node[:kibana][:install_dir] do
  owner 'root'
  group 'root'
  mode '0755'
  recursive true
  action :create
end

filename = node[:kibana][:deb_url].split('/').last
remote_file "/tmp/#{filename}" do
  source node[:kibana][:deb_url]
  checksum node[:kibana][:deb_sha]
  mode 00644
  notifies :run, 'script[install_kibana]'
end

filename_remove_extension = filename.dup
filename_remove_extension.slice!(/\.tar\.gz/)
script "install_kibana" do
  action :nothing
  interpreter "bash"
  user        "root"
  code <<-EOL
    tar zxvf /tmp/#{filename} -C /tmp
    cp -rp /tmp/#{filename_remove_extension}/* #{node[:kibana][:install_dir]}
  EOL
end

template "#{node[:kibana][:install_dir]}/config.js" do
  source 'config.js.erb'
  owner 'root'
  group 'root'
  mode '0744'
end
