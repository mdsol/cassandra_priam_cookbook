#
# Cookbook Name:: cassandra-priam
# Recipe:: simpledbconfig
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

## SimpleDB Configuration Recipe

# Delayed installation of packages.
buildessential = package "build-essential" do
  action:nothing
end

xsltdev = package "libxslt-dev" do
  action :nothing
end

xmldev = package "libxml2-dev" do
  action :nothing
end

buildessential.run_action(:install)
xsltdev.run_action(:install)
xmldev.run_action(:install)

chef_gem "fog" do
  version node[:cassandra][:fog][:version] 
end

# we attempt to automatically set the cluster_name based on the role name - this is sensible in the Author's opinion.
# you can always force your own clustername if you desire, but it really should match the autoscaling group's name (everthing before the first dash "-")
if node['cassandra']['priam_clustername'] == "SET_ME_PLEASE"
  CLUSTERNAME = node[:roles].first.gsub("-", "_")
  Chef::Log.info("Setting Cluster Name to #{CLUSTERNAME} because no name was specified")
  node.set[:cassandra][:priam_clustername] = CLUSTERNAME
end

# Warn if the bucket is still poorly named.
if node['cassandra']['priam_s3_bucket'] == "SET_ME_PLEASE"
   Chef::Log.warn("You should set the [:cassandra][:priam_s3_bucket] to something other than #{node['cassandra']['priam_s3_bucket']}")
end

ruby_block "set-SimpleDB-Properties" do
  block do
    require 'fog'

    # We read the credentials from the same place that Priam will.
    keys = Hash[File.read("/etc/awscredential.properties").split.map{|e| e.split("=") }]
    sdb = Fog::AWS::SimpleDB.new(:aws_access_key_id => keys["AWSACCESSID"], :aws_secret_access_key => keys["AWSKEY"])

    # We create databases if they have not already been - this is safe behaviour.
    sdb.create_domain("InstanceIdentity")
    sdb.create_domain("PriamProperties")

    # consider using batch_put_attributes for speed in the future
    # http://docs.aws.amazon.com/AmazonSimpleDB/latest/DeveloperGuide/SDB_API_BatchPutAttributes.html

    # default safe single and multi-region attributes
    sdb.put_attributes("PriamProperties", "#{node['cassandra']['priam_clustername']}.priam.s3.bucket", {"appId" => "#{node['cassandra']['priam_clustername']}", "property" => "priam.s3.bucket", "value" => "#{node['cassandra']['priam_s3_bucket']}"}, options = { :replace => ["value"] })
    sdb.put_attributes("PriamProperties", "#{node['cassandra']['priam_clustername']}.priam.s3.base_dir", {"appId" => "#{node['cassandra']['priam_clustername']}", "property" => "priam.s3.base_dir", "value" => "#{node['cassandra']['priam_s3_base_dir']}"}, options = { :replace => ["value"] })
    sdb.put_attributes("PriamProperties", "#{node['cassandra']['priam_clustername']}.priam.clustername", {"appId" => "#{node['cassandra']['priam_clustername']}", "property" => "priam.clustername", "value" => "#{node['cassandra']['priam_clustername']}"}, options = { :replace => ["value"] })
    sdb.put_attributes("PriamProperties", "#{node['cassandra']['priam_clustername']}.priam.endpoint_snitch", {"appId" => "#{node['cassandra']['priam_clustername']}", "property" => "priam.endpoint_snitch", "value" => "#{node['cassandra']['priam_endpoint_snitch']}"}, options = { :replace => ["value"] })
    sdb.put_attributes("PriamProperties", "#{node['cassandra']['priam_clustername']}.priam.data.location", {"appId" => "#{node['cassandra']['priam_clustername']}", "property" => "priam.data.location", "value" => "#{node['cassandra']['priam_data_location']}"}, options = { :replace => ["value"] })
    sdb.put_attributes("PriamProperties", "#{node['cassandra']['priam_clustername']}.priam.cache.location", {"appId" => "#{node['cassandra']['priam_clustername']}", "property" => "priam.cache.location", "value" => "#{node['cassandra']['priam_cache_location']}"}, options = { :replace => ["value"] })
    sdb.put_attributes("PriamProperties", "#{node['cassandra']['priam_clustername']}.priam.commitlog.location", {"appId" => "#{node['cassandra']['priam_clustername']}", "property" => "priam.commitlog.location", "value" => "#{node['cassandra']['priam_commitlog_location']}"}, options = { :replace => ["value"] })
    sdb.put_attributes("PriamProperties", "#{node['cassandra']['priam_clustername']}.priam.cass.home", {"appId" => "#{node['cassandra']['priam_clustername']}", "property" => "priam.cass.home", "value" => "#{node['cassandra']['priam_cass_home']}"}, options = { :replace => ["value"] })
    sdb.put_attributes("PriamProperties", "#{node['cassandra']['priam_clustername']}.priam.cass.startscript", {"appId" => "#{node['cassandra']['priam_clustername']}", "property" => "priam.cass.startscript", "value" => "#{node['cassandra']['priam_cass_startscript']}"}, options = { :replace => ["value"] })
    sdb.put_attributes("PriamProperties", "#{node['cassandra']['priam_clustername']}.priam.cass.stopscript", {"appId" => "#{node['cassandra']['priam_clustername']}", "property" => "priam.cass.stopscript", "value" => "#{node['cassandra']['priam_cass_stopscript']}"}, options = { :replace => ["value"] })
    sdb.put_attributes("PriamProperties", "#{node['cassandra']['priam_clustername']}.priam.upload.throttle", {"appId" => "#{node['cassandra']['priam_clustername']}", "property" => "priam.upload.throttle", "value" => "#{node['cassandra']['priam_upload_throttle']}"}, options = { :replace => ["value"] })
    
    # unsafe attribute : present but empty on certain deployments this breaks them

    # priam.multiregion.enable should only be created if it is true - otherwise, if there is a record present, priam will try to modify a security group unnecessarily and we may not want that behaviour.
    if node['cassandra']['priam_multiregion_enable'] == "true"
      sdb.put_attributes("PriamProperties", "#{node['cassandra']['priam_clustername']}.priam.multiregion.enable", {"appId" => "#{node['cassandra']['priam_clustername']}", "property" => "priam.multiregion.enable", "value" => "#{node['cassandra']['priam_multiregion_enable']}"}, options = { :replace => ["value"] })
    end

    # priam.zones.available should not be created if there is no non-nil (i.e. overriding) chef node attribute for it - reason: it breaks single-region deployments. caveat: must be set for multi-region deployments.
    if node['cassandra']['priam_zones_available'] != nil
      sdb.put_attributes("PriamProperties", "#{node['cassandra']['priam_clustername']}.priam.zones.available", {"appId" => "#{node['cassandra']['priam_clustername']}", "property" => "priam.zones.available", "value" => "#{node['cassandra']['priam_zones_available']}"}, options = { :replace => ["value"] })
    end

  end
  action :create
end

##########################
