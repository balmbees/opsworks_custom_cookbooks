include_recipe 'runit::default'

runit_service "sidekiq" do
  options({
    :queue => "default,counter,analytics",
    :workers_count => node[:sidekiq][:default_workers_count]
  })
end

runit_service "sidekiqnewsfeed" do
  options({
    :queue => "newsfeed",
    :workers_count => node[:sidekiq][:newsfeed_workers_count]
  })
end

runit_service "sidekiqemail" do
  options({
    :queue => "email_notification",,
    :workers_count => node[:sidekiq][:email_workers_count]
  })
end

runit_service "sidekiqmobile" do
  options({
    :queue => "mobile_notification",,
    :workers_count => node[:sidekiq][:mobile_workers_count]
  })
end

