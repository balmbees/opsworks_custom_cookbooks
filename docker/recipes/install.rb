case node[:platform]
when "ubuntu","debian"
  execute "install docker" do
    command "curl -sSL https://get.docker.com/ubuntu/ | sudo sh"
  end
when 'centos','redhat','fedora','amazon'
  package "docker" do
    action :install
  end
end

service "docker" do
  action :start
end
