execute 'Stop newrelic' do
  command "docker stop $(docker ps -a | grep nrsysmond | awk '{print $1}')"

  only_if do
    ::File.exist?('/usr/bin/docker') && OpsWorks::ShellOut.shellout('docker ps -a').include?('nrsysmond')
  end
end

execute 'Remove newrelic' do
  command "docker rm $(docker ps -a | grep nrsysmond | awk '{print $1}')"

  only_if do
    ::File.exist?('/usr/bin/docker') && OpsWorks::ShellOut.shellout('docker ps -a').include?('nrsysmond')
  end
end
