case node[:platform]
when "ubuntu","debian"
  execute "install docker" do
    command "curl -sSL https://get.docker.com/| sudo sh; echo \"DOCKER_OPTS='-g /mnt/docker/ -p /var/run/docker.pid'\" >> /etc/default/docker ; groupadd docker; gpasswd -a ubuntu docker; service docker restart"
  end
when 'centos','redhat','fedora','amazon'
  package "docker" do
    action :install
  end
end

service "docker" do
  action :start
end
