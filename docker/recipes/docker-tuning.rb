Chef::Log.info("Tweak Kernel parameters")
bash "tweak-kernal-params" do
  user "root"
  code <<-EOH
      echo 'Backup previous sysctl configurations to sysctl-backup.list...'
      sysctl -a | tee sysctl-backup`date +"%Y-%m-%d_%H-%M-%S"`.list
      
      printf '\n\n\n...\n\n\n\n\n'
      
      # Turn on TCP window scaling
      printf '\n\n====> Turn on TCP window scaling feature...\n'
      sysctl -w net.ipv4.tcp_window_scaling="1"
      
      # Increase TCP socket buffer size
      printf '\n\n====> Increasing TCP socket buffer size...\n'
      sysctl -w net.core.rmem_default="253952"
      sysctl -w net.core.wmem_default="253952"
      sysctl -w net.core.rmem_max="16777216"
      sysctl -w net.core.wmem_max="16777216"
      sysctl -w net.ipv4.tcp_rmem="253952 253952 16777216"
      sysctl -w net.ipv4.tcp_wmem="253952 253952 16777216"
      
      # Increase inbound backlog queue length
      printf '\n\n====> Increasing inbound backlog queue length...\n'
      sysctl -w net.core.netdev_max_backlog="30000"
      
      # Increase outbound backlog queue length
      printf '\n\n====> Increasing outbound backlog queue length...\n'
      ulimit -Hn 65535
      ulimit -Sn 65535
      sysctl -w net.core.somaxconn="1024"
      sysctl -w net.ipv4.tcp_max_syn_backlog="1024"
      
      # Increase local port range
      printf '\n\n====> Increasing local port range....\n'
      sysctl -w net.ipv4.ip_local_port_range="10240 65535"
      
      # Increase TIME_WAIT state socket buckets
      printf '\n\n====> Increasing TIME_WAIT state socket buckets...\n'
      sysctl -w net.ipv4.tcp_max_tw_buckets="1800000"
      
      # Turn on TIME_WAIT state socket re-use ability
      printf '\n\n====> Turn on TIME_WAIT state socket re-use ability...\n'
      sysctl -w net.ipv4.tcp_timestamps="1"
      sysctl -w net.ipv4.tcp_tw_reuse="1"
      
      printf '\n\n==========> Done.\n'
  EOH
end