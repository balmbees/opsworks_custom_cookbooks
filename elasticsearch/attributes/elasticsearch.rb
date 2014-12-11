default[:elasticsearch][:deb_url] = "https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.4.1.deb"
default[:elasticsearch][:deb_sha] = "4ca792a50cdc1cf6fa2a8aa0ff12394ab1450135"

default[:elasticsearch][:setting] = {
  "index.number_of_shards" => "3",
  "index.number_of_replicas" => "0",
  "path.conf" => "/etc/elasticsearch",
  "path.data" => "/elb/data",
  "path.logs" => "/var/log/elasticsearch",
  "script.disable_dynamic" => "false",
  "indices.fielddata.cache.size" => "40%"
}

default[:elasticsearch][:env] = {
  :es_heap_size => "8g"
}
