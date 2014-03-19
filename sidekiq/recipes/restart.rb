include_recipe 'runit::default'

def reload_service(service)
  begin
    execute "reload #{service}" do
      command "sv force-reload #{service}"
    end
  rescue Mixlib::ShellOut::ShellCommandFailed
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

