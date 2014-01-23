name              "td_updater"
maintainer        "Opscode, Inc."
maintainer_email  "cookbooks@opscode.com"
license           "Apache 2.0"
description       "Configures apt and apt services and LWRPs for managing apt repositories and preferences"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           "0.0.1"
recipe            "td_updater", "Install software for td_updater"

%w{ ubuntu }.each do |os|
  supports os
end
