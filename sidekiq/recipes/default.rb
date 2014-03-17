include_recipe 'runit::default'

runit_service "sidekiq" do
  owner "deploy"
  group "www-data"
  default_logger true
end

