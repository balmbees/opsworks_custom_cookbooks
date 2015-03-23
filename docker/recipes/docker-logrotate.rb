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
    [ ! -f /var/run/nginx.pid ] || kill -USR1 `cat /var/run/nginx.pid`
    rm -rf /var/lib/logstash/.sincedb*
  EOF
end

