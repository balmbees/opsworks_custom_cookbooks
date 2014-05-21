require 'chefspec'

describe 'remote_syslog::gem ' do
  let (:chef_run) { ChefSpec::ChefRunner.new.converge 'remote_syslog::gem' }

  it 'should do something' do
    chef_run.should install_gem_package 'remote_syslog'
  end
end
