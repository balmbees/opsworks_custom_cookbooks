set[:logstash][:instance][:server][:elasticsearch_ip] = OpsWorksUtils::Helpers::layer_elb(node, 'elasticsearch')
set[:logstash][:instance][:server][:elasticsearch_cluster] = 'logstash'
set[:logstash][:instance][:server][:enable_embedded_es] = false
set[:logstash][:instance][:server][:config_templates_cookbook] = 'opsworks_logstash'
set[:logstash][:instance][:server][:config_templates] = {
    'server' => 'server.conf.erb',
}

set['logstash']['instance']['default']['version']        = '1.4.2'
set['logstash']['instance']['default']['source_url']     = 'https://download.elasticsearch.org/logstash/logstash/logstash-1.4.2.tar.gz'
set['logstash']['instance']['default']['checksum']       = 'd5be171af8d4ca966a0c731fc34f5deeee9d7631319e3660d1df99e43c5f8069'

set['logstash']['instance']['default']['plugins_version']        = '1.4.2'
set['logstash']['instance']['default']['plugins_source_url']     = 'https://download.elasticsearch.org/logstash/logstash/logstash-contrib-1.4.2.tar.gz'
set['logstash']['instance']['default']['plugins_checksum']       = '7497ca3614ba9122159692cc6e60ffc968219047e88de97ecc47c2bf117ba4e5'
