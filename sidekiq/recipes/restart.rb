runit_service "sidekiq"

service "runit_service[sidekiq]" do
  action :restart
end

