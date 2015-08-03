include_recipe 'deploy'

node[:deploy].each do |application, deploy|
  cookbook_file "/tmp/td.sh" do
    source "td.sh"
    mode 0755
  end

  template "/etc/crontab.conf" do
    mode "0644"
    source "crontab.conf.erb"
  end

  execute "setup crontab" do
    command "crontab /etc/crontab.conf"
  end
end

