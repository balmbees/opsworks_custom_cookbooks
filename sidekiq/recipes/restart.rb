include_recipe 'runit::default'

runit_service "sidekiq" do
  owner "deploy"
  group "www-data"
  action :restart
  default_logger true
end

