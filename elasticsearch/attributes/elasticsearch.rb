default[:elasticsearch][:deb_url] = "https://download.elastic.co/elasticsearch/elasticsearch/elasticsearch-1.7.3.deb"
default[:elasticsearch][:deb_sha] = "6335601147c0bbbdcd780cade8e2b3040a0795bb"

default[:elasticsearch][:setting] = {
  "index.number_of_shards" => "3",
  "index.number_of_replicas" => "0",
  "path.conf" => "/etc/elasticsearch",
  "path.data" => "/mnt/data",
  "path.logs" => "/var/log/elasticsearch",
  "script.disable_dynamic" => "false",
  "indices.fielddata.cache.size" => "40%",
  "action.disable_delete_all_indices" => "true",
  "node" => { "name" => node[:opsworks][:instance][:hostname] }
}

default[:elasticsearch][:env] = {
  :es_heap_size => "8g"
}
