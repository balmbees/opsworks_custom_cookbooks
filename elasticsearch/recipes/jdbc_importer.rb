script "install_jdbc_importer" do
  interpreter "bash"
  user "ubuntu"
  cwd "/home/ubuntu/"

  code <<-EOH
  wget http://xbib.org/repository/org/xbib/elasticsearch/importer/elasticsearch-jdbc/#{node[:elasticsearch][:plugin]['elasticsearch-jdbc']}/elasticsearch-jdbc-#{node[:elasticsearch][:plugin]['elasticsearch-jdbc']}-dist.zip
  unzip elasticsearch-jdbc-#{node[:elasticsearch][:plugin]['elasticsearch-jdbc']}-dist.zip
  EOH
end
