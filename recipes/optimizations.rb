#
# Cookbook Name:: cassandra-priam
# Recipe:: optimizations
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

# cassandra performance optimizations, based on Datastax best practices:
# http://www.datastax.com/documentation/cassandra/2.0/webhelp/index.html#cassandra/install/installRecommendSettings.html

# allow cassandra more memory and more open filehandles
file "/etc/security/limits.d/cassandra.conf" do
  mode    0644
  content <<-EOF
#{node[:cassandra][:user]} soft as unlimited
#{node[:cassandra][:user]} hard as unlimited
root soft as unlimited
root hard as unlimited
#{node[:cassandra][:user]} soft memlock unlimited
#{node[:cassandra][:user]} hard memlock unlimited
root soft memlock unlimited
root hard memlock unlimited
#{node[:cassandra][:user]} soft nofile 100000
#{node[:cassandra][:user]} hard nofile 100000
root soft nofile 100000
root hard nofile 100000
#{node[:cassandra][:user]} soft nproc 32768
#{node[:cassandra][:user]} hard nproc 32768
root soft nproc 32768
root hard nproc 32768
EOF
end

# increase the maximum number of memory map areas a process may have
# http://kernel.org/doc/Documentation/sysctl/vm.txt
execute "Increase the maximum number of memory map areas" do
  max_vms = 131072
  command "echo #{max_vms}  > /proc/sys/vm/max_map_count"
  not_if {File.read('/proc/sys/vm/max_map_count').to_i >= max_vms}
end
