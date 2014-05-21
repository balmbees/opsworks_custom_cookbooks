require 'chefspec'

describe 'remote_syslog::configure' do
  let (:chef_run) { ChefSpec::ChefRunner.new.converge 'remote_syslog::configure' }

  it 'should render /etc/log_files.yml' do
    chef_run.should create_file "/etc/log_files.yml"
  end
end
