name = 'server'

Chef::Application.fatal!("attribute hash node['logstash']['instance']['#{name}'] must exist.") if node['logstash']['instance'][name].nil?

execute 'allow java to bind on <1024 ports' do
  command 'setcap cap_net_bind_service=+ep $(realpath $(which java))'
end

logstash_instance name do
  action :create
end

logstash_service name do
  action [:enable]
end

config_variables = node[:logstash][:instance][:default]
config_variables = config_variables.merge(node[:logstash][:instance][:default][:config_templates_variables])
if node['logstash']['instance'][name] and node['logstash']['instance'][name][:config_templates_variables]
  config_variables = config_variables.merge(node['logstash']['instance'][name])
  config_variables = config_variables.merge(node['logstash']['instance'][name][:config_templates_variables])
end

logstash_config name do
  variables config_variables
  action [:create]
end

logstash_plugins 'contrib' do
  instance name
  action [:create]
end

logstash_pattern name do
  action [:create]
end

logstash_service name do
  action [:start]
end
