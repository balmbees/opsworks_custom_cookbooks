include_recipe 'runit::default'

apt_package "ttf-vlgothic" do
  action :install
end

runit_service "sidekiq" do
  options({
    :queues => ["default", "counter", "coverpage", "research"],
    :workers_count => node[:sidekiq][:default_workers_count]
  })
end

runit_service "sidekiqnewsfeed" do
  options({
    :queues => ["newsfeed"],
    :workers_count => node[:sidekiq][:newsfeed_workers_count]
  })
end

runit_service "sidekiqemail" do
  options({
    :queues => ["email_notification"],
    :workers_count => node[:sidekiq][:email_workers_count]
  })
end

runit_service "sidekiqmobile" do
  options({
    :queues => ["mobile_notification"],
    :workers_count => node[:sidekiq][:mobile_workers_count]
  })
end

