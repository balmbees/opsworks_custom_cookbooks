include_recipe 'runit::default'

runit_service "sidekiq" do
  options(params)
end
