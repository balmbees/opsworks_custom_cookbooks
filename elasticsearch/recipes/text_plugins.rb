script "install_plugin_es" do
  interpreter "bash"
  user "root"
  cwd "/usr/share/elasticsearch/"
  code <<-EOH
  bin/plugin -i elasticsearch/elasticsearch-analysis-icu/2.4.3
  bin/plugin -i elasticsearch/elasticsearch-analysis-smartcn/2.4.4
  bin/plugin -i elasticsearch/elasticsearch-analysis-kuromoji/2.4.3
  bin/plugin -i analysis-mecab-ko-0.16.3 -u https://bitbucket.org/eunjeon/mecab-ko-lucene-analyzer/downloads/elasticsearch-analysis-mecab-ko-0.16.3.zip
  wget https://bitbucket.org/eunjeon/mecab-ko-dic/downloads/mecab-ko-dic-1.6.1-20140814.tar.gz
  tar xvzf mecab-ko-dic-1.6.1-20140814.tar.gz
  cd mecab-ko-dic-1.6.1-20140814/
  ./autogen.sh
  ./configure
  make && make install

  bin/plugin -i jdbc -u http://xbib.org/repository/org/xbib/elasticsearch/plugin/elasticsearch-river-jdbc/1.4.0.8/elasticsearch-river-jdbc-1.4.0.8-plugin.zip
  wget https://jdbc.postgresql.org/download/postgresql-9.3-1103.jdbc41.jar
  cp postgresql-9.3-1103.jdbc41.jar /usr/share/elasticsearch/plugins/jdbc/

  bin/plugin -i mobz/elasticsearch-head
  bin/plugin -i elasticsearch/elasticsearch-cloud-aws/2.4.2
  EOH
  not_if { File.exist?("/usr/share/elasticsearch/plugins/head") }
end

#notifies :restart, 'service[elasticsearch]' unless node.elasticsearch[:skip_restart]
