default[:elasticsearch][:deb_url] = "https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.4.5.deb"
default[:elasticsearch][:deb_sha] = "ad91bc487b423032858eb00e9c2c87f485aa28ac"

default[:elasticsearch][:setting] = {
  "index.number_of_shards" => "3",
  "index.number_of_replicas" => "0",
  "path.conf" => "/etc/elasticsearch",
  "path.data" => "/elb/data",
  "path.logs" => "/var/log/elasticsearch",
  "script.disable_dynamic" => "false",
  "indices.fielddata.cache.size" => "40%"
  "action.disable_delete_all_indices" => "true"
}

default[:elasticsearch][:env] = {
  :es_heap_size => "8g"
}
