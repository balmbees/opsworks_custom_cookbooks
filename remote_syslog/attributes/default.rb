default.remote_syslog.init_style = "init"
default.remote_syslog.conf.files = ["/srv/www/vingle/shared/log/*.log"]
default.remote_syslog.destination.host = "logs.papertrailapp.com"
# default.remote_syslog.destination.port = 22537

# Unused
default.remote_syslog.tcp = false
default.remote_syslog.tls = false
