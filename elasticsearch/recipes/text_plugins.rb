script "install_plugin_es" do
  interpreter "bash"
  user "root"
  cwd "/usr/share/elasticsearch/"
  code <<-EOH
  bin/plugin -i elasticsearch/elasticsearch-analysis-icu/2.4.1
  bin/plugin -i elasticsearch/elasticsearch-analysis-smartcn/2.4.2
  bin/plugin -i analysis-mecab-ko-0.16.0 -u https://bitbucket.org/eunjeon/mecab-ko-lucene-analyzer/downloads/elasticsearch-analysis-mecab-ko-0.16.0.zip
  bin/plugin -i elasticsearch/elasticsearch-analysis-kuromoji/2.4.1
  bin/plugin -i jdbc -u http://xbib.org/repository/org/xbib/elasticsearch/plugin/elasticsearch-river-jdbc/1.4.0.8/elasticsearch-river-jdbc-1.4.0.8-plugin.zip
  bin/plugin -i mobz/elasticsearch-head
  EOH
  not_if { File.exist?("/usr/share/elasticsearch/plugins/head") }
end

#notifies :restart, 'service[elasticsearch]' unless node.elasticsearch[:skip_restart]
