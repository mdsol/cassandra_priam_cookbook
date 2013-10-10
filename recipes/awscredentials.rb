#
# Cookbook Name:: cassandra-priam
# Recipe:: awscredentials
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

# Get credentials
# Taken from the ebs cookbook - kudos to them
if node[:cassandra][:aws][:encrypted]
  credentials = Chef::EncryptedDataBagItem.load(node[:cassandra][:aws][:databag], node[:cassandra][:aws][:item])
else
  credentials = data_bag_item node[:cassandra][:aws][:databag], node[:cassandra][:aws][:item]
end

# We pick up the defined items.
aws_access_key = credentials[node.cassandra.aws.aki]
aws_secret_access_key = credentials[node.cassandra.aws.sak]

# And then create the AWS credentials for Priam
template "/etc/awscredential.properties" do
  source "awscredential.properties.erb"
  owner     "#{node[:tomcat][:user]}"
  group     "#{node[:tomcat][:group]}"
  mode      "0640"
  variables ({
    :access_key_id => aws_access_key,
    :secret_access_key => aws_secret_access_key
  })
end

