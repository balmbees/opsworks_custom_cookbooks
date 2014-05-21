#!/usr/bin/env bats

@test "/etc/log_files.yml should be present" {
  [ -f /etc/log_files.yml ]
}

@test "/etc/init.d/remote_syslog should be present" {
  [ -f /etc/init.d/remote_syslog ]
}

@test "remote_syslog should start on boot" {
  [ "$(chkconfig --list remote_syslog | grep '3:on')" ]
}
