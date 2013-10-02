log "Installing Opscenter Server"

# download source
src_url = node[:cassandra][:opscenter][:src_url]
local_archive = "#{Chef::Config[:file_cache_path]}/#{::File.basename src_url}"
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

# link the opscenter_home to the version directory
link node[:cassandra][:opscenter_home] do
  to        VERSION_DIR
  owner     "#{node[:cassandra][:user]}"
  group     "#{node[:tomcat][:user]}"
end

# opscenter server configuration
template "#{node[:cassandra][:opscenter_home]}/conf/opscenterd.conf" do
  source "opscenterd.conf.erb"
  owner     "#{node[:cassandra][:user]}"
  group     "#{node[:tomcat][:user]}"
  mode      "0640"
end

# start it up
execute "Start Datastax OpsCenter" do
  command   "#{node[:cassandra][:opscenter_home]}/bin/opscenter"
  user      "#{node[:cassandra][:user]}"
  group     "#{node[:tomcat][:user]}"
  cwd       node[:cassandra][:opscenter_home]
  not_if    "pgrep -f start_opscenter.py"
end

# set nginx-readable permissions on agent.tar.gz
file "#{node[:cassandra][:opscenter_home]}/agent.tar.gz" do
  owner     "#{node[:cassandra][:user]}"
  group     "#{node[:tomcat][:user]}"
  mode      0644
  only_if  { ::File.exists?("#{node[:cassandra][:opscenter_home]}/agent.tar.gz") }
end

# setup nginx
include_recipe "nginx_proxy"

# Provide access to the agent.tar.gz on the leader via http/https
rewind :template => "/etc/nginx/sites-available/nginx_proxy" do
  source "nginx_proxy.erb"
  cookbook_name "priam-cassandra" 
end

# make sure we start nginx mid-run
service "nginx" do
  action [ :enable, :start ]
end

