#
# Cookbook Name:: cassandra-priam
# Recipe:: install
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

# Some external dependencies
include_recipe "sudo"
include_recipe "runit"
include_recipe "java"
include_recipe "tomcat"

# Setup up performance optimizations
include_recipe "cassandra-priam::optimizations"

# Install JNA
package node[:cassandra][:jnapackagename]

# Install cassandra server
include_recipe "cassandra-priam::cassandra"

# AWS credentials - needed to apply simpledb config and used by Priam for various functions.
include_recipe "cassandra-priam::awscredentials"

## Simplistic leader election
node.save
peers = search(:node, "roles:#{node[:roles].first}" )
leader = peers.sort{|a,b| a.name <=> b.name}.first || node # the "or" covers the case where node is the first db

# Some reporting on the election
Chef::Log.info("cassandra-priam LeaderElection: #{node[:roles].first} Leader is : #{leader.name} #{leader.ec2.public_hostname} #{leader.ipaddress}")

if (node.name == leader.name)
  # If we're the leader we always run this config
  include_recipe "cassandra-priam::simpledbconfig"
elsif (leader.uptime_seconds < 900)
  # If the leader node has just started.. we apply the config any
  include_recipe "cassandra-priam::simpledbconfig"
end

# Install priam cluster management - this starts Cassandra
include_recipe "cassandra-priam::priam"

