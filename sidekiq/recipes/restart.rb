include_recipe 'runit::default'

runit_service "sidekiq" do
  action :reload
  options({
    :queues => ["default", "counter", "analytics"],
    :workers_count => node[:sidekiq][:default_workers_count]
  })
end

runit_service "sidekiqnewsfeed" do
  action :reload
  options({
    :queues => ["newsfeed"],
    :workers_count => node[:sidekiq][:newsfeed_workers_count]
  })
end

runit_service "sidekiqemail" do
  action :reload
  options({
    :queues => ["email_notification"],
    :workers_count => node[:sidekiq][:email_workers_count]
  })
end

runit_service "sidekiqmobile" do
  action :reload
  options({
    :queues => ["mobile_notification"],
    :workers_count => node[:sidekiq][:mobile_workers_count]
  })
end

