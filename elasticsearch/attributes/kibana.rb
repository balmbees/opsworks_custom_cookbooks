default[:kibana][:deb_url] = "https://download.elasticsearch.org/kibana/kibana/kibana-3.1.0.tar.gz"
default[:kibana][:deb_sha] = "059a4b6b507b9ff771901d12035e499b0e8d1cae7d9e5284633e19da6c294e07"

default[:kibana][:es_url] = "http://\"+window.location.hostname+\":9200"
default[:kibana][:install_dir] = "/usr/share/kibana3"
