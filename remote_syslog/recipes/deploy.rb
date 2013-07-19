node[:deploy].each do |application, deploy|
  Chef::Log.debug("Running remote_syslog::deploy for Rails application #{application}")

  template "/etc/log_files.yml" do
    source "log_files.yml.erb"
    owner "root"
    group "root"
    mode 0644
    variables :application => application, :deploy => deploy
  end

  execute "start remote_syslog" do
    command "remote_syslog restart"
    user "root"
  end
end
