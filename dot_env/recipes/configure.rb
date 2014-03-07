if node[:opsworks][:instance][:layers].include?('rails-app')
  include_recipe "dot_env::restart_command"
  include_recipe "dot_env::write_config"
end
