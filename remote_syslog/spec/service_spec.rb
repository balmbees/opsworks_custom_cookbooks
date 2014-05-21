require 'chefspec'

describe 'remote_syslog::service' do
  let (:chef_run) { ChefSpec::ChefRunner.new.converge 'remote_syslog::service' }

  it 'should create the init file' do
    chef_run.should create_cookbook_file "/etc/init.d/remote_syslog"
  end

  it "should enable to service" do
    chef_run.should enable_service "remote_syslog"
    chef_run.should start_service  "remote_syslog"
  end
end
