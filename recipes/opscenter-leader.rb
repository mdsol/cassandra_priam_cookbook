# required for IO stat reporting
package "sysstat"

# required for opscenter to run
package "libssl0.9.8"

# download source
src_url = node[:cassandra][:opscenter][:src_url]
local_archive = "/usr/local/src/#{::File.basename src_url}"
remote_file local_archive do
  source  src_url
  mode    0644
  not_if  { File.exists? local_archive }
  checksum node[:cassandra][:opscenter][:checksum]
end

VERSION_DIR = "#{node[:cassandra][:opscenter_home]}-#{node[:cassandra][:opscenter][:version]}"

# create the target directory
directory VERSION_DIR do
  owner     "#{node[:cassandra][:user]}"
  group     "#{node[:tomcat][:user]}"
  mode      0775
  recursive true
end

# unpack
execute "unpack #{local_archive}" do
  command   "tar --strip-components 1 --no-same-owner -xzf #{local_archive}"
  creates   "#{VERSION_DIR}/bin/opscenter"
  user      "#{node[:cassandra][:user]}"
  group     "#{node[:tomcat][:user]}"
  cwd       VERSION_DIR
end

# link the priam_cass_home to the version directory
link node[:cassandra][:opscenter_home] do
  to        VERSION_DIR
  owner     "#{node[:cassandra][:user]}"
  group     "#{node[:tomcat][:user]}"
end

# start it up
execute "Start Datastax OpsCenter" do
  command   "#{node[:cassandra][:opscenter_home]}/bin/opscenter"
  not_if    "ps -ef | grep twistd | grep -v grep"
  user      "#{node[:cassandra][:user]}"
  group     "#{node[:tomcat][:user]}"
  cwd       node[:cassandra][:opscenter_home]
end

# set readable permissions on agent.tar.gz
file "#{node[:cassandra][:opscenter_home]}/agent.tar.gz" do
  mode      0644
end

include_recipe "nginx_proxy"

# Provide access to the agent.tar.gz on the leader via http/https
rewind :template => "/etc/nginx/sites-available/nginx_proxy" do
  source "nginx_proxy.erb"
  cookbook_name "priam-cassandra" 
end

