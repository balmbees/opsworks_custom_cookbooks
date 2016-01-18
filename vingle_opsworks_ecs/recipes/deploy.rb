Chef::Log.info('cleanup docker images')
bash 'cleanup docker images' do
  user 'root'
  code <<-EOH
    docker rm -v `docker ps -a -q -f status=exited` || true # Delete stopped containers
    docker rmi $(docker images -q -f dangling=true) || true # Delete dangling images
    docker volume rm $(docker volume ls -q -f dangling=true) || true # Delete dangling volumes
  EOH
end
