package "openjdk-7-jre"

execute "add-postgresql-repository" do
  command "wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -"
end

execute "setup-postgresql-repository" do
  command "sh -c 'echo \"deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main\" >> /etc/apt/sources.list.d/postgresql.list'"
end

execute "update packages" do
  command "apt-get update"
end

package "postgresql-9.3"

