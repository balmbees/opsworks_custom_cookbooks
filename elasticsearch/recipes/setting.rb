template "/etc/default/elasticsearch" do
  source "setting.erb"
  variables( :config => node[:elasticsesarch][:setting] )
  notifies :restart, "service[elasticsesarch]"
end
