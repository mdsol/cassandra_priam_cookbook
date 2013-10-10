#
# Cookbook Name:: cassandra-priam
# Recipe:: priam
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

# Sudo entry to manage cassandra startup/shutdown via Priam
template "/etc/sudoers.d/tomcat" do
  source "tomcatsudo.erb"
  mode    0440
end

# Priam's agent jar 
src_url = node[:cassandra][:priam_cass_extensions_jar][:src_url]
local_archive = "#{node[:cassandra][:priam_cass_home]}/lib/#{::File.basename src_url}"
remote_file local_archive do
  source  src_url
  mode    0644
  not_if  { File.exists? local_archive }
  checksum node[:cassandra][:priam_cass_extensions_jar][:checksum]
end

# Give priam running as node[:tomcat][:user] access to write the Cassandra config
file "#{node[:cassandra][:priam_cass_home]}/conf/cassandra.yaml" do
  owner     "#{node[:tomcat][:user]}"
  group     "#{node[:tomcat][:group]}"
  mode      "0755"
  action    :touch
end

# pull in the original cassandra.in.sh from where it lies in the cassandra home
# concatenate the Priam agent onto the end of the file
# copy the file where it will be picked up
# sadly doing this a chef-way is too bothersome compared to shellscript
bash "Setup Agent in Cassandra Include File" do
  user node[:cassandra][:user]
  cwd "/"
  code <<-EOH
  cp #{node[:cassandra][:priam_cass_home]}/bin/cassandra.in.sh /tmp
  echo "export JVM_OPTS=\"-javaagent:\\$CASSANDRA_HOME/lib/priam-cass-extensions-#{node[:cassandra][:priam_version]}.jar\"" >> /tmp/cassandra.in.sh
  cp /tmp/cassandra.in.sh #{node[:cassandra][:priam_cass_home]}/
  EOH
  not_if "grep #{node[:cassandra][:priam_version]} #{node[:cassandra][:priam_cass_home]}/cassandra.in.sh"
end

# Priam's War file goes into tomcat's special directory - this event causes Priam to start running.
# When Priam runs, it configures cassandra and starts it, either replacing a lost node or booting a new one.
src_url = node[:cassandra][:priam_web_war][:src_url]
local_archive = "#{node[:tomcat][:webapp_dir]}/Priam.war"
remote_file local_archive do
  source  src_url
  mode    0644
  not_if  { File.exists? local_archive }
  checksum node[:cassandra][:priam_web_war][:checksum]
end

