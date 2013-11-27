node[:deploy].each do |application, deploy|
  execute "move /tmp folder" do
    command "mv /tmp /mnt/tmp; ln -s /mnt/tmp /tmp"
    action :run
    not_if { ::File.exists?("/mnt/tmp")}
  end
end
