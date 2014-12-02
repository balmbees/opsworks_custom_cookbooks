default[:elasticsearch][:deb_url] = "https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.3.2.deb"
default[:elasticsearch][:deb_sha] = "156a38c5a829e5002ae8147c6cac20effe6cd065"

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