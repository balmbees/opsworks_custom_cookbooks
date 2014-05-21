case node.remote_syslog.init_style
when "init"
  cookbook_file "/etc/init.d/remote_syslog" do
    source "remote_syslog.init"
    owner "root"
    group "root"
    mode "0755"
  end
else
  raise "Unsupported init style"
end

service "remote_syslog" do
  action [:start, :enable]
end
