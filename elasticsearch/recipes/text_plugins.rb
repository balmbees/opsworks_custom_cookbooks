script "install_plugin_es" do
  interpreter "bash"
  user "root"
  cwd "/usr/share/elasticsearch/"

  # only compatible until 1.5.0 : must rewrite after 1.5.2
  code <<-EOH
  bin/plugin -i mobz/elasticsearch-head

  bin/plugin -i elasticsearch/elasticsearch-analysis-icu/#{node[:elasticsearch][:plugin]['elasticsearch-analysis-icu']}
  bin/plugin -i elasticsearch/elasticsearch-analysis-smartcn/#{node[:elasticsearch][:plugin]['elasticsearch-analysis-smartcn']}
  bin/plugin -i elasticsearch/elasticsearch-analysis-kuromoji/#{node[:elasticsearch][:plugin]['elasticsearch-analysis-kuromoji']}
  bin/plugin -i elasticsearch/elasticsearch-cloud-aws/#{node[:elasticsearch][:plugin]['elasticsearch-cloud-aws']}

  bin/plugin -i analysis-mecab-ko-0.16.3 -u https://bitbucket.org/eunjeon/mecab-ko-lucene-analyzer/downloads/elasticsearch-analysis-mecab-ko-0.16.3.zip

  wget https://bitbucket.org/eunjeon/mecab-ko-dic/downloads/mecab-ko-dic-1.6.1-20140814.tar.gz
  tar xvzf mecab-ko-dic-1.6.1-20140814.tar.gz
  cd mecab-ko-dic-1.6.1-20140814/
  ./autogen.sh
  ./configure
  make && make install
  cd ..

  bin/plugin -i jdbc -u http://xbib.org/repository/org/xbib/elasticsearch/plugin/elasticsearch-river-jdbc/1.4.4.5/elasticsearch-river-jdbc-1.4.4.5-plugin.zip
  wget https://jdbc.postgresql.org/download/#{node[:elasticsearch][:plugin]['pg-jdbc-driver']}
  mv #{node[:elasticsearch][:plugin]['pg-jdbc-driver']} /usr/share/elasticsearch/plugins/jdbc/
  EOH
  not_if { File.exist?("/usr/share/elasticsearch/plugins/head") }
end

#notifies :restart, 'service[elasticsearch]' unless node.elasticsearch[:skip_restart]
