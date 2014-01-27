swap_file node['swap']['file'] do
  size node['swap']['size']
  action :create
end
