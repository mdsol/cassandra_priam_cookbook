#
# Cookbook Name:: cassandra-priam
# Recipe:: cassandra
#
# Copyright 2013 Medidata Solutions Worldwide
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# POSIX user - we create it under tomcat's gid for ease of restorate/backups.
user "#{node[:cassandra][:user]}" do
  system    true
  home      node[:cassandra][:priam_cass_home]
  gid       node[:tomcat][:group]
  shell     "/bin/sh"
end

# Create the Data/Cache/Commitlog/Log Directories
[ node[:cassandra][:priam_data_location],
  node[:cassandra][:priam_cache_location],
  node[:cassandra][:priam_commitlog_location],
  node[:cassandra][:log_dir]  
].each do |dir|
  directory dir do
    owner     "#{node[:cassandra][:user]}"
    group     "#{node[:tomcat][:group]}"
    mode      0770
    recursive true
  end
end

# download source
src_url = node[:cassandra][:src_url]
local_archive = "#{Chef::Config[:file_cache_path]}/#{::File.basename src_url}"
remote_file local_archive do
  source  src_url
  mode    0644
  not_if  { File.exists? local_archive }
  checksum node[:cassandra][:checksum]
end

VERSION_DIR = "#{node[:cassandra][:parentdir]}/#{node[:cassandra][:nameprefix]}-#{node[:cassandra][:version]}"

# create the target directory
directory VERSION_DIR do
  owner     "#{node[:cassandra][:user]}"
  group     "#{node[:tomcat][:group]}"
  mode      0775
  recursive true
end

# unpack to the versioned directory first
execute "unpack #{local_archive}" do
  command   "tar --strip-components 1 --no-same-owner -xzf #{local_archive}"
  creates   "#{VERSION_DIR}/bin/cassandra"
  user      "#{node[:cassandra][:user]}"
  group     "#{node[:tomcat][:group]}"
  cwd       VERSION_DIR
end

# link the priam_cass_home to the version directory
link node[:cassandra][:priam_cass_home] do
  to        VERSION_DIR
  owner     "#{node[:cassandra][:user]}"
  group     "#{node[:tomcat][:group]}"
end

# link in Java Native interface, if found
link "#{node[:cassandra][:priam_cass_home]}/lib/jna.jar" do
  to "/usr/share/java/jna.jar"
  only_if { ::File.exists? "/usr/share/java/jna.jar" }
end

# create a runit service for cassandra and immediately stop it.
# this uses templates which abstract the interesting parts.
# Priam starts cassandra when it starts up.
# We will not bother trying to recreate/stop the service once the Cassandra daemon is running.
runit_service "cassandra" do
  action :enable
  env({ 'HOME' => node[:cassandra][:priam_cass_home] })
  not_if "pgrep -f CassandraDaemon"
  notifies :stop, "runit_service[cassandra]", :immediately
end
