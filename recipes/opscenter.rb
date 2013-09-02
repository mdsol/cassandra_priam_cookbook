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


# This needs to be rewritten so that:
# A master is elected (oldest node, first in a list, whatever)
# Slave nodes launch pointed at the master using the agent/bin/opscenter-agent instead
# PITA 
# Not sure how to force twistd to the forground yet, 
# so start it in the background, but not_if it's already running
execute "Start Datastax OpsCenter" do
  command   "#{node[:cassandra][:opscenter_home]}/bin/opscenter"
  not_if    "ps -ef | grep twistd | grep -v grep"
  user      "#{node[:cassandra][:user]}"
  group     "#{node[:tomcat][:user]}"
  cwd       node[:cassandra][:opscenter_home]
end

# Section to setup the agents
# including some sort of master detection :/
# agents run out of the agents dir.

include_recipe "nginx_proxy"
