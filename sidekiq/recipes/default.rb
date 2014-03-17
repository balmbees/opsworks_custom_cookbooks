include_recipe 'runit::default'

runit_service "sidekiq" do
  default_logger true
end

