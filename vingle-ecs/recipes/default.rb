bash "init ecs" do
  user "root"
  code <<-EOH
    yum install -y ecs-init
    service docker start
    start ecs

    echo 'ECS_CLUSTER=#{node[:ecs][:cluster]}' >> /etc/ecs/ecs.config
    echo 'ECS_ENGINE_AUTH_TYPE=docker' >> /etc/ecs/ecs.config
    echo 'ECS_ENGINE_AUTH_DATA={"https://index.docker.io/v1/":{"auth":"#{node[:common][:DOCKER_AUTHCODE]}","email":"#{node[:common][:DOCKER_EMAIL]}"}}' >> /etc/ecs/ecs.config
    /bin/sed -i "s,^\(HOSTNAME=\).*,\1HOSTNAME," /etc/sysconfig/network
    rpm -Uvh https://yum.newrelic.com/pub/newrelic/el5/x86_64/newrelic-repo-5-3.noarch.rpm
    yum -y install newrelic-sysmond
    nrsysmond-config --set license_key=#{node[:common][:NEWRELIC_KEY]}
    /etc/init.d/newrelic-sysmond start
  EOH
end
