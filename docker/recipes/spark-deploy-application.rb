include_recipe "cron"

directory "/spark_app/" do
  owner "root"
  group "root"
  mode "0755"
  recursive true
  action :create
end

template "/spark_app/soft_fandoms.py" do
  source "soft_fandoms.py"
  mode '0644'
end

cron_d "soft_fandoms" do
  minute "5"
  hour "0"
  command "docker exec spark bash -c 'spark-submit --master spark://#{node[:custom_env][:spark][:MASTER_IP]}:7077 --packages org.apache.hadoop:hadoop-aws:2.7.1 --conf spark.akka.frameSize=50 /spark_app/soft_fandoms.py'"
end
