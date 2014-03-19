include_recipe 'runit::default'

service "sidekiq" do
  retries 3
  action :reload
end

service "sidekiqnewsfeed" do
  retries 3
  action :reload
end

service "sidekiqemail" do
  retries 3
  action :reload
end

service "sidekiqmobile" do
  retries 3
  action :reload
end

