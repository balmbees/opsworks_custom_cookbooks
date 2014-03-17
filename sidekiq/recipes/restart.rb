runit_service "sidekiq"

notifies :restart, "runit_service[sidekiq]"

