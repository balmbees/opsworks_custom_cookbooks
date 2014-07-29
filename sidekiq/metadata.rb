name 'sidekiq'

recipe 'sidekiq', 'Run sidekiq with runit'
recipe 'sidekiq::restart', 'Restart sidekiq'

depends "runit"
depends "apt"
