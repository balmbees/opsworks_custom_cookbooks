include_recipe 'runit::default'

execute "reload sidekiq" do
  command "sv force-reload sidekiq"
end

execute "reload sidekiqnewsfeed" do
  command "sv force-reload sidekiqnewsfeed"
end

execute "reload sidekiqemail" do
  command "sv force-reload sidekiqemail"
end

execute "reload sidekiqmobile" do
  command "sv force-reload sidekiqmobile"
end

