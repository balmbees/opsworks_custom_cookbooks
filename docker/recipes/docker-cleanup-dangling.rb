execute 'Remove stopped containers' do
  command ['/usr/bin/docker',
           'rm',
           '-v',
           '`/usr/bin/docker ps -a -q -f status=exited`'].join(' ')

  only_if do
    ::File.exist?('/usr/bin/docker')
  end

  ignore_failure true
end

execute 'Remove dangling images' do
  command ['/usr/bin/docker',
           'rmi',
           '$(/usr/bin/docker images -q -f dangling=true)'].join(' ')

  only_if do
    ::File.exist?('/usr/bin/docker')
  end

  ignore_failure true
end

execute 'Remove dangling volumes' do
  command ['/usr/bin/docker',
           'volume',
           'rm',
           '-v',
           '$(/usr/bin/docker volume ls -q -f dangling=true)'].join(' ')

  only_if do
    ::File.exist?('/usr/bin/docker')
  end

  ignore_failure true
end
