## SimpleDB Configuration Recipe

package "build-essential"
package "libxslt-dev"
package "libxml2-dev"

chef_gem "fog" do
  version node[:cassandra][:fog][:version] 
end

# we attempt to automatically set the cluster_name based on the role name - this is sensible in the Author's opinion.
# you can always force your own clustername if you desire, but it really should match the autoscaling group's name (everthing before the first dash "-")
if node['cassandra']['priam_clustername'] == "SET_ME_PLEASE"
  CLUSTERNAME = node[:roles].first.gsub("-", "_")
  log "INFO: Setting Cluster Name to #{CLUSTERNAME}"
  node.set[:cassandra][:priam_clustername] = CLUSTERNAME
end

# Warn if the bucket is still poorly named.
if node['cassandra']['priam_s3_bucket'] == "SET_ME_PLEASE"
  log "WARNING: You should set the [:cassandra][:priam_s3_bucket] to something other than #{node['cassandra']['priam_s3_bucket']}"
end

ruby_block "set-SimpleDB-Properties" do
  block do
      require 'fog'

      keys = Hash[File.read("/etc/awscredential.properties").split.map{|e| e.split("=") }]
      sdb = Fog::AWS::SimpleDB.new(:aws_access_key_id => keys["AWSACCESSID"], :aws_secret_access_key => keys["AWSKEY"])

      sdb.create_domain("InstanceIdentity")
      sdb.create_domain("PriamProperties")

      # consider using batch_put_attributes for speed in the future
      # http://docs.aws.amazon.com/AmazonSimpleDB/latest/DeveloperGuide/SDB_API_BatchPutAttributes.html

      # default safe single and multi-region attributes
      sdb.put_attributes("PriamProperties", "#{node['cassandra']['priam_clustername']}.priam.s3.bucket", {"appId" => "#{node['cassandra']['priam_clustername']}", "property" => "priam.s3.bucket", "value" => "#{node['cassandra']['priam_s3_bucket']}"})
      sdb.put_attributes("PriamProperties", "#{node['cassandra']['priam_clustername']}.priam.s3.base_dir", {"appId" => "#{node['cassandra']['priam_clustername']}", "property" => "priam.s3.base_dir", "value" => "#{node['cassandra']['priam_s3_base_dir']}"})
      sdb.put_attributes("PriamProperties", "#{node['cassandra']['priam_clustername']}.priam.clustername", {"appId" => "#{node['cassandra']['priam_clustername']}", "property" => "priam.clustername", "value" => "#{node['cassandra']['priam_clustername']}"})
      sdb.put_attributes("PriamProperties", "#{node['cassandra']['priam_clustername']}.priam.endpoint_snitch", {"appId" => "#{node['cassandra']['priam_clustername']}", "property" => "priam.endpoint_snitch", "value" => "#{node['cassandra']['priam_endpoint_snitch']}"})
      sdb.put_attributes("PriamProperties", "#{node['cassandra']['priam_clustername']}.priam.data.location", {"appId" => "#{node['cassandra']['priam_clustername']}", "property" => "priam.data.location", "value" => "#{node['cassandra']['priam_data_location']}"})
      sdb.put_attributes("PriamProperties", "#{node['cassandra']['priam_clustername']}.priam.cache.location", {"appId" => "#{node['cassandra']['priam_clustername']}", "property" => "priam.cache.location", "value" => "#{node['cassandra']['priam_cache_location']}"})
      sdb.put_attributes("PriamProperties", "#{node['cassandra']['priam_clustername']}.priam.commitlog.location", {"appId" => "#{node['cassandra']['priam_clustername']}", "property" => "priam.commitlog.location", "value" => "#{node['cassandra']['priam_commitlog_location']}"})
      sdb.put_attributes("PriamProperties", "#{node['cassandra']['priam_clustername']}.priam.cass.home", {"appId" => "#{node['cassandra']['priam_clustername']}", "property" => "priam.cass.home", "value" => "#{node['cassandra']['priam_cass_home']}"})
      sdb.put_attributes("PriamProperties", "#{node['cassandra']['priam_clustername']}.priam.cass.startscript", {"appId" => "#{node['cassandra']['priam_clustername']}", "property" => "priam.cass.startscript", "value" => "#{node['cassandra']['priam_cass_startscript']}"})
      sdb.put_attributes("PriamProperties", "#{node['cassandra']['priam_clustername']}.priam.cass.stopscript", {"appId" => "#{node['cassandra']['priam_clustername']}", "property" => "priam.cass.stopscript", "value" => "#{node['cassandra']['priam_cass_stopscript']}"})
      sdb.put_attributes("PriamProperties", "#{node['cassandra']['priam_clustername']}.priam.upload.throttle", {"appId" => "#{node['cassandra']['priam_clustername']}", "property" => "priam.upload.throttle", "value" => "#{node['cassandra']['priam_upload_throttle']}"})
      
      # unsafe attribute : present but empty on certain deployments this breaks them

      # priam.multiregion.enable should only be created if it isn't false - otherwise, if there is a record present, priam will try to modify a security group unnecessarily
      if node['cassandra']['priam_multiregion_enable'] != "false"
        sdb.put_attributes("PriamProperties", "#{node['cassandra']['priam_clustername']}.priam.multiregion.enable", {"appId" => "#{node['cassandra']['priam_clustername']}", "property" => "priam.multiregion.enable", "value" => "#{node['cassandra']['priam_multiregion_enable']}"})
      end

      # priam.zones.available should not be created if there is no non-nil (i.e. overriding) chef node attribute for it - reason: it breaks single-region deployments. caveat: must be set for multi-region deployments.
      if node['cassandra']['priam_zones_available'] != nil
        sdb.put_attributes("PriamProperties", "#{node['cassandra']['priam_clustername']}.priam.zones.available", {"appId" => "#{node['cassandra']['priam_clustername']}", "property" => "priam.zones.available", "value" => "#{node['cassandra']['priam_zones_available']}"})
      end

  end
  action :create
end

##########################
