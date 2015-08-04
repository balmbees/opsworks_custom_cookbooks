include_recipe 'deploy'

node[:deploy].each do |application, deploy|
  template "/tmp/td.sh" do
    user "ubuntu"
    source "td.sh"
    mode 0755
  end

  template "/etc/crontab.conf" do
    user "ubuntu"
    mode "0644"
    source "crontab.conf.erb"
  end

  execute "setup crontab" do
    user "ubuntu"
    command "crontab -u ubuntu /etc/crontab.conf"
  end
end

