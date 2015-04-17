#
# Cookbook Name:: td-agent
# Recipe:: default
#
# Copyright 2011, Treasure Data, Inc.
#

group 'td-agent' do
  group_name 'td-agent'
  gid        403
  action     [:create]
end

user 'td-agent' do
  comment  'td-agent'
  uid      403
  group    'td-agent'
  home     '/var/run/td-agent'
  # shell    '/bin/false'
  shell    "/bin/bash"
  password nil
  supports :manage_home => true
  action   [:create, :manage]
end

directory '/etc/td-agent/' do
  owner  'td-agent'
  group  'td-agent'
  mode   '0755'
  action :create
end

template "/etc/td-agent/td-agent.conf" do
  mode "0644"
  source "td-agent.conf.erb"
  variables :env => node[:custom_env][:vingle]
end

if node['td_agent']['includes']
  directory "/etc/td-agent/conf.d" do
    mode "0755"
  end
end

execute "install td-agent" do
  command "curl -L http://toolbelt.treasuredata.com/sh/install-ubuntu-trusty-td-agent2.sh | sh"
end

node[:td_agent][:plugins].each do |plugin|
  if plugin.is_a?(Hash)
    plugin_name, plugin_attributes = plugin.first
    td_agent_gem plugin_name do
      plugin true
      %w{action version source options gem_binary}.each do |attr|
        send(attr, plugin_attributes[attr]) if plugin_attributes[attr]
      end
    end
  elsif plugin.is_a?(String)
    td_agent_gem plugin do
      plugin true
    end
  end
end

execute "git clone balmbees/fluent-plugin-redshift" do
  command "git clone https://github.com/balmbees/fluent-plugin-redshift"
end

execute "build fluent-plugin-redshift" do
  command "/opt/td-agent/embedded/bin/fluent-gem build fluent-plugin-redshift/fluent-plugin-redshift.gemspec"
end

execute "install fluent-plugin-redshift" do
  command "/opt/td-agent/embedded/bin/fluent-gem install ./fluent-plugin-redshift/fluent-plugin-redshift-0.0.4.gem"
end

service "td-agent" do
  action [ :enable, :start ]
  subscribes :restart, resources(:template => "/etc/td-agent/td-agent.conf")
end
