include_recipe 'runit::default'

runit_service "sidekiq" do
  options({
    :queue => node[:sidekiq][:queue]
  })
end

