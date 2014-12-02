template "/etc/default/elasticsearch" do
  source "setting.erb"
  notifies :restart, "service[elasticsesarch]"
end
