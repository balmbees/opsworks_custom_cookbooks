include_recipe 'runit::default'

runit_service "sidekiq" do
  action :restart
end

