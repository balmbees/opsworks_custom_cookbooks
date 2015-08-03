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
  command "/usr/local/bin/s3cmd --config /root/.s3cfg put #{node[:rediss3][:rdb_path]}/#{node[:rediss3][:rdb_filename]} s3://#{node[:rediss3][:s3_prefix]}/#{node[:opsworks][:instance][:hostname]}/#{node[:rediss3][:rdb_filename]}_`/bin/date \"+\\\%Y-\\\%m-\\\%d-\\\%H\"`"
  user    "root"
  path    "/usr/local/bin"
end

bash "restore from backups" do
  user "root"
  cwd "#{node[:rediss3][:rdb_path]}"

  code <<-EOH
    FFILENAME=#{node[:rediss3][:rdb_filename]}
    FFILESIZE=$(stat -c %s "$FFILENAME")

    for HTIME in {21,17,13,9,5,1}
    do
      FILENAME=#{node[:rediss3][:rdb_filename]}
      FILESIZE=$(stat -c %s "$FILENAME")

      if [ $FILESIZE -lt #{1024*1024*10} ]
      then
        /usr/local/bin/s3cmd --config /root/.s3cfg get s3://#{node[:rediss3][:s3_prefix]}/#{node[:opsworks][:instance][:hostname]}/#{node[:rediss3][:rdb_filename]}_#{Date.today.strftime}-$HTIME #{node[:rediss3][:rdb_filename]} --force
      fi
    done

    for HTIME in {21,17,13,9,5,1}
    do
      FILENAME=#{node[:rediss3][:rdb_filename]}
      FILESIZE=$(stat -c %s "$FILENAME")

      if [ $FILESIZE -lt #{1024*1024*10} ]
      then
        /usr/local/bin/s3cmd --config /root/.s3cfg get s3://#{node[:rediss3][:s3_prefix]}/#{node[:opsworks][:instance][:hostname]}/#{node[:rediss3][:rdb_filename]}_#{Date.today.prev_day.strftime}-$HTIME #{node[:rediss3][:rdb_filename]} --force
      fi
    done

    SFILENAME=#{node[:rediss3][:rdb_filename]}
    SFILESIZE=$(stat -c %s "$SFILENAME")

    if [ $SFILESIZE -ne $SFILESIZE ]
    then
      service redis6379 stop
      service redis6379 start
    fi
  EOH
  
  Chef::Log.info(<<-EOH
    FFILENAME=#{node[:rediss3][:rdb_filename]}
    FFILESIZE=$(stat -c %s "$FFILENAME")

    for HTIME in {21,17,13,9,5,1}
    do
      FILENAME=#{node[:rediss3][:rdb_filename]}
      FILESIZE=$(stat -c %s "$FILENAME")

      if [ $FILESIZE -lt #{1024*1024*10} ]
      then
        /usr/local/bin/s3cmd --config /root/.s3cfg get s3://#{node[:rediss3][:s3_prefix]}/#{node[:opsworks][:instance][:hostname]}/#{node[:rediss3][:rdb_filename]}_#{Date.today.strftime}-$HTIME #{node[:rediss3][:rdb_filename]}
      fi
    done

    for HTIME in {21,17,13,9,5,1}
    do
      FILENAME=#{node[:rediss3][:rdb_filename]}
      FILESIZE=$(stat -c %s "$FILENAME")

      if [ $FILESIZE -lt #{1024*1024*10} ]
      then
        /usr/local/bin/s3cmd --config /root/.s3cfg get s3://#{node[:rediss3][:s3_prefix]}/#{node[:opsworks][:instance][:hostname]}/#{node[:rediss3][:rdb_filename]}_#{Date.today.prev_day.strftime}-$HTIME #{node[:rediss3][:rdb_filename]}
      fi
    done

    SFILENAME=#{node[:rediss3][:rdb_filename]}
    SFILESIZE=$(stat -c %s "$SFILENAME")

    if [ $SFILESIZE -ne $SFILESIZE ]
    then
      service redis6379 stop
      service redis6379 start
    fi
  EOH
  )
end
