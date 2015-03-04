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
  hour    "0,4,8,12,16,20"
  command "/usr/local/bin/redis-cli bgsave"
  user    "root"
  path    "/usr/local/bin"
end

cron_d 's3-cron' do
  minute  "0"
  hour    "1,5,9,13,17,21"
  command "/usr/local/bin/s3cmd --config /root/.s3cfg put #{node[:rediss3][:rdb_path]}/#{node[:rediss3][:rdb_filename]} s3://#{node[:rediss3][:s3_prefix]}/#{node[:opsworks][:instance][:hostname]}/#{node[:rediss3][:rdb_filename]}_`date \"+\%Y-\%m-\%d-\%H\"`"
  user    "root"
  path    "/usr/local/bin"
end

