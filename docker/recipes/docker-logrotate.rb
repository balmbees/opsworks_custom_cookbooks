include_recipe "logrotate"

logrotate_app "nginx" do
  rotate 52
  cookbook "logrotate"
  path "/mnt/var/log/nginx/*.log"
  create "0644 www-data adm"
  frequency "daily"
  options ["compress", "delaycompress", "sharedscripts", "notifempty"]
  prerotate <<-EOF
    if [ -d /etc/logrotate.d/httpd-prerotate ]; then
      run-parts /etc/logrotate.d/httpd-prerotate;
    fi
  EOF
  postrotate <<-EOF
    sudo docker exec -it unicorn_rails sh -c 'cat /var/run/nginx.pid | xargs kill -USR1'
    sudo docker exec -it unicorn_rails sh -c 'rm -rf /var/lib/logstash/.sincedb*'
  EOF
end
