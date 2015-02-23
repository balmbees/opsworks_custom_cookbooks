#
# Cookbook Name:: rediss3
# Recipe:: default
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
include_recipe 'cron'

cron_d 'redis-cron' do
  minute  "0"
  hour    "*/4+#{node[:opsworks][:instance][:hostname].scan(/\d+/).first % 4}"
  command "redis-cli bgsave && sleep 3600 && s3cmd --config /root/.s3cfg put #{node[:rediss3][:rdb_path]}/#{node[:rediss3][:rdb_filename]} s3://#{node[:rediss3][:s3_prefix]}/#{node[:opsworks][:instance][:hostname]}/#{node[:rediss3][:rdb_filename]}"
  user    "root"
  path    "/usr/local/bin"
end
