template "/etc/default/logstash" do
  source "setting.erb"
  variables( :config => node[:logstash][:setting] )
  notifies :restart, "service[logstash]"
end
