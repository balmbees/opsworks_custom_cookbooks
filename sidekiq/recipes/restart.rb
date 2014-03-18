include_recipe 'runit::default'

runit_service "sidekiq" do
  action :restart
  options({
    :queue => "default,counter,analytics",
    :workers_count => node[:sidekiq][:default_workers_count]
  })
end

runit_service "sidekiqnewsfeed" do
  action :restart
  options({
    :queue => "newsfeed",
    :workers_count => node[:sidekiq][:newsfeed_workers_count]
  })
end

runit_service "sidekiqemail" do
  action :restart
  options({
    :queue => "email_notification",
    :workers_count => node[:sidekiq][:email_workers_count]
  })
end

runit_service "sidekiqmobile" do
  action :restart
  options({
    :queue => "mobile_notification",
    :workers_count => node[:sidekiq][:mobile_workers_count]
  })
end

