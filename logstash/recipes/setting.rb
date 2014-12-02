template "/etc/default/logstash" do
  source "setting.erb"
  notifies :restart, "service[logstash]"
end
