# Example config file
#files:
#  - /var/log/httpd/access_log
#  - /var/log/httpd/error_log
#  - /opt/misc/*.log
#  - /var/log/mysqld.log
#  - /var/run/mysqld/mysqld-slow.log
#hostname: www42   # override OS hostname
#parse_fields: syslog   # predefined regex name or double-quoted regex
#exclude_patterns:
#  - exclude this
#  - \d+ things
#destination:
#  host: logs.papertrailapp.com
#  port: 12345   # optional, defaults to 514

template "/etc/log_files.yml" do
  source "log_files.erb"
  owner "root"
  group "root"
  mode  "0644"

  # TODO make this a .to_yaml, issue with getting extra data
  variables :files       => node.remote_syslog.conf.files,
            :destination => node.remote_syslog.destination
end
