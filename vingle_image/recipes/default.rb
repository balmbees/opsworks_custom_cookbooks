node[:deploy].each do |application, deploy|
  execute "move /tmp folder" do
    command "mv /tmp /mnt/tmp"
    action :nothing
  end

  execute "link /mnt/tmp folder" do
    command "ln -s /mnt/tmp /tmp"
    action :nothing
  end
end
