#
# Cookbook Name:: chef-logstash
# Recipe:: default
#
# Copyright (C) 2014 Wouter de Vos
# 
# License: MIT
#

include_recipe "logstash::yumrepo" if platform_family? "rhel", "fedora"
include_recipe "logstash::apt"     if platform_family? "debian"

## resolving logrotate
include_recipe "logrotate"

logrotate_app "nginx" do
  rotate 52
  cookbook "logrotate"
  path "/var/log/nginx/*.log"
  create "0644 www-data adm"
  frequency "daily"
  options ["compress", "delaycompress", "sharedscripts", "notifempty"]
  prerotate <<-EOF
    if [ -d /etc/logrotate.d/httpd-prerotate ]; then
      run-parts /etc/logrotate.d/httpd-prerotate;
    fi
  EOF
  postrotate <<-EOF
    [ ! -f /var/run/nginx.pid ] || kill -USR1 `cat /var/run/nginx.pid`
    rm -rf /var/lib/logstash/.sincedb*
  EOF
end
##

directory "/etc/logstash" do
  owner "logstash"
  group "logstash"
  mode "0755"
end

directory "/etc/logstash/conf.d" do
  owner "logstash"
  group "logstash"
  mode "0755"
end

directory "/var/lib/monit" do
  owner "logstash"
  group "logstash"
  mode "0755"
end

package "logstash"

execute "remove-server-conf" do
  command %{
    if [ -e /etc/logstash/conf.d/server.conf ]; then
      rm /etc/logstash/conf.d/server.conf
    fi
  }
  not_if { node[:logstash][:server][:enabled] }
end

execute "remove-agent-conf" do
  command %{
    if [ -e /etc/logstash/conf.d/agent.conf ]; then
      rm /etc/logstash/conf.d/agent.conf
    fi
  }
  not_if { node[:logstash][:agent][:enabled] }
end

service "logstash" do
  supports :restart => true, :reload => false
  action :nothing
  provider Chef::Provider::Service::Upstart
end

include_recipe "logstash::server" if node[:logstash][:server][:enabled]
include_recipe "logstash::agent"  if node[:logstash][:agent][:enabled]

# Patch the elasticsearch_http plugin.
include_recipe "logstash::elasticsearch_http" if node[:logstash][:server][:enabled]
