include_recipe 'runit::default'

# runit_service "sidekiq" do
#   action :restart
#   options({
#     :queues => ["default", "counter"],
#     :workers_count => node[:sidekiq][:default_workers_count]
#   })
# end

# runit_service "sidekiqnewsfeed" do
#   action :restart
#   options({
#     :queues => ["newsfeed"],
#     :workers_count => node[:sidekiq][:newsfeed_workers_count]
#   })
# end

# runit_service "sidekiqemail" do
#   action :restart
#   options({
#     :queues => ["email_notification"],
#     :workers_count => node[:sidekiq][:email_workers_count]
#   })
# end

# runit_service "sidekiqmobile" do
#   action :restart
#   options({
#     :queues => ["mobile_notification"],
#     :workers_count => node[:sidekiq][:mobile_workers_count]
#   })
# end

def reload_service(service)
  begin
    Chef::Log.info("sv force-reload #{service}")
    command = Mixlib::ShellOut.new("sv force-reload #{service}")
    command.run_command
    command.error!
  rescue Mixlib::ShellOut::ShellCommandFailed => e
    Chef::Log.info("Failed: sv force-reload #{service} #{e.message}")
    return false
  end
  true
end

services = ["sidekiq", "sidekiqnewsfeed", "sidekiqemail", "sidekiqmobile"]
max_retries = 3

services.each do |service|
  max_retries.times.each do
    break if reload_service(service)
    sleep(2)
  end
end
