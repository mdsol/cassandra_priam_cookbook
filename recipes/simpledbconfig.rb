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
# package dependencies
%w{build-essential libxslt-dev libxml2-dev}.each {|pkg| package pkg}

# we attempt to automatically set the cluster_name based on the role name -
# this is sensible in the Author's opinion.
# you can always force your own clustername if you desire, but it really should
# match the autoscaling group's name (everthing before the first dash "-")
if node['cassandra']['priam_clustername'] == node.default['cassandra']['priam_clustername']
  CLUSTERNAME = node[:roles].first.gsub("-", "_")
  Chef::Log.info("Setting Cluster name to #{CLUSTERNAME} because no name was specified")
  node.set[:cassandra][:priam_clustername] = CLUSTERNAME
end

# Warn if the bucket is still poorly named.
if node['cassandra']['priam_s3_bucket'] == node.default['cassandra']['priam_s3_bucket']
   Chef::Log.warn("You should set the [:cassandra][:priam_s3_bucket] to "+
    "something other than #{node['cassandra']['priam_s3_bucket']}")
end

chef_gem 'aws-sdk'
ruby_block "set-SimpleDB-Properties" do
  block do
    require 'aws-sdk'
    # We read the credentials from the same place that Priam will.
    creds_file  = "/etc/awscredential.properties"
    keys        = Hash[File.read(creds_file).split.map{|e| e.split("=") }]
    sdb         = AWS::SimpleDB.new(
      :access_key_id      => keys["AWSACCESSID"],
      :secret_access_key  => keys["AWSKEY"]
    )
    # create domains as needed
    %w{PriamProperties InstanceIdentity}.each do |domain_name|
      sdb.domains.create(domain_name) unless sdb.domains[domain_name].exists?
    end
    # default safe single and multi-region attributes
    defaults = { # Hash maps SDB Item names (Strings) to each value
      's3.bucket'           => node['cassandra']['priam_s3_bucket'],
      's3.base_dir'         => node['cassandra']['priam_s3_base_dir'],
      'clustername'         => node['cassandra']['priam_clustername'],
      'data.location'       => node['cassandra']['priam_data_location'],
      'endpoint_snitch'     => node['cassandra']['priam_endpoint_snitch'],
      'cache.location'      => node['cassandra']['priam_cache_location'],
      'commitlog.location'  => node['cassandra']['priam_commitlog_location'],
      'cass.home'           => node['cassandra']['priam_cass_home'],
      'cass.startscript'    => node['cassandra']['priam_cass_startscript'],
      'cass.stopscript'     => node['cassandra']['priam_cass_stopscript'],
      'upload.throttle'     => node['cassandra']['priam_upload_throttle'],
    }

    # unsafe attributes : present but empty on certain deployments this breaks them
    # priam.multiregion.enable should only be created if it is true - otherwise,
    # if there is a record present, priam will try to modify a security group
    # unnecessarily and we may not want that behaviour.
    if node['cassandra']['priam_multiregion_enable'] == "true"
      defaults.merge!('multiregion.enable' =>
        node['cassandra']['priam_multiregion_enable'])
    end
    # priam.zones.available should not be created if there is no non-nil
    # (i.e. overriding) chef node attribute for it - reason: it breaks single-region
    # deployments. caveat: must be set for multi-region deployments.
    if node['cassandra']['priam_zones_available'] != nil
      defaults.merge!('zones.available' =>
        node['cassandra']['priam_zones_available'])
    end
    # Now set all values in SimpleDB
    defaults.each do |name, value|
      item_name = "#{node['cassandra']['priam_clustername']}.priam.#{name}"
      Chef::Log.debug "Setting SimpleDB attribute in #{item_name} to #{value}"
      sdb.domains['PriamProperties'].items.create(item_name,
          "appId"     => node['cassandra']['priam_clustername'],
          "property"  => "priam.#{name}",
          "value"     => value
      )
    end
  end
end
