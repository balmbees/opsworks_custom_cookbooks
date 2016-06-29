script "install_plugin_es" do
  interpreter "bash"
  user "root"
  cwd "/usr/share/elasticsearch/"

  if node[:elasticsearch][:version].to_f >= 2.0
    code_plugins = <<-EOH
      bin/plugin install mobz/elasticsearch-head

      bin/plugin install analysis-icu
      bin/plugin install analysis-smartcn
      bin/plugin install analysis-kuromoji
      bin/plugin install cloud-aws
      bin/plugin install https://bitbucket.org/eunjeon/mecab-ko-lucene-analyzer/downloads/elasticsearch-analysis-mecab-ko-#{node[:elasticsearch][:plugin]['elasticsearch-mecab-ko']}.zip
      wget https://bitbucket.org/eunjeon/mecab-ko-dic/downloads/mecab-ko-dic-2.0.1-20150920.tar.gz
      tar xvzf mecab-ko-dic-2.0.1-20150920.tar.gz
      cd mecab-ko-dic-2.0.1-20150920/
    EOH
  else
    code_plugins = <<-EOH
      bin/plugin -i mobz/elasticsearch-head

      bin/plugin -i elasticsearch/elasticsearch-analysis-icu/#{node[:elasticsearch][:plugin]['elasticsearch-analysis-icu']}
      bin/plugin -i elasticsearch/elasticsearch-analysis-smartcn/#{node[:elasticsearch][:plugin]['elasticsearch-analysis-smartcn']}
      bin/plugin -i elasticsearch/elasticsearch-analysis-kuromoji/#{node[:elasticsearch][:plugin]['elasticsearch-analysis-kuromoji']}
      bin/plugin -i elasticsearch/elasticsearch-cloud-aws/#{node[:elasticsearch][:plugin]['elasticsearch-cloud-aws']}
      bin/plugin -i analysis-mecab-ko-0.16.3 -u https://bitbucket.org/eunjeon/mecab-ko-lucene-analyzer/downloads/elasticsearch-analysis-mecab-ko-0.16.3.zip

      wget https://bitbucket.org/eunjeon/mecab-ko-dic/downloads/mecab-ko-dic-1.6.1-20140814.tar.gz
      tar xvzf mecab-ko-dic-1.6.1-20140814.tar.gz
      cd mecab-ko-dic-1.6.1-20140814/
    EOH
  end

  code <<-EOH
  #{code_plugins}

  ./autogen.sh
  ./configure
  make && make install
  cd ..

  wget http://xbib.org/repository/org/xbib/elasticsearch/importer/elasticsearch-jdbc/#{node[:elasticsearch][:plugin]['elasticsearch-jdbc']}/elasticsearch-jdbc-#{node[:elasticsearch][:plugin]['elasticsearch-jdbc']}-dist.zip
  unzip elasticsearch-jdbc-#{node[:elasticsearch][:plugin]['elasticsearch-jdbc']}-dist.zip
  EOH
  not_if { File.exist?("/usr/share/elasticsearch/plugins/head") }
end

#notifies :restart, 'service[elasticsearch]' unless node.elasticsearch[:skip_restart]
