execute "setup-mtu" do
  command "ifconfig eth0 mtu 1500"
end
