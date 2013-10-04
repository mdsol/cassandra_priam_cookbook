## SimpleDB Recipe
# This recipe applies the simpledb configuration through just one node in the cluster.
# This is done on only one node because it only needs to be done once, and amazon returns 503s if too many API calls happen.
# We run this each run in case a variable is updated.

node.save

# A simplistic leadership election
# This search returns all other nodes sharing the unique? role
peers = search(:node, "roles:#{node[:roles].first}" )
# Leader is elected based on lowest numeric hostname
leader = peers.sort{|a,b| a.name <=> b.name}.first

########################## 
if (node.name == leader.name)

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
  version  "1.9.0"
end

# we attempt to automatically set the cluster_name based on the role name - this is sensible in our opinion.
if node[:cassandra][:priam_clustername] = "SET_ME_PLEASE"
  CLUSTERNAME = node[:roles].first.gsub("-", "_")
  log "Setting Cluster Name to #{CLUSTERNAME}"
  node.set[:cassandra][:priam_clustername] = CLUSTERNAME
end

if node[:cassandra][:priam_s3_bucket] = "SET_ME_PLEASE"
  log "If you want backups to work then you should set the [:cassandra][:priam_s3_bucket] attribute"
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

      sdb.put_attributes("PriamProperties", "#{node['cassandra']['priam_clustername']}.priam.s3.bucket", {"appId" => "#{node['cassandra']['priam_clustername']}", "property" => "priam.s3.bucket", "value" => "#{node['cassandra']['priam_s3_bucket']}"})
      sdb.put_attributes("PriamProperties", "#{node['cassandra']['priam_clustername']}.priam.s3.base_dir", {"appId" => "#{node['cassandra']['priam_clustername']}", "property" => "priam.s3.base_dir", "value" => "#{node['cassandra']['priam_s3_base_dir']}"})
      sdb.put_attributes("PriamProperties", "#{node['cassandra']['priam_clustername']}.priam.clustername", {"appId" => "#{node['cassandra']['priam_clustername']}", "property" => "priam.clustername", "value" => "#{node['cassandra']['priam_clustername']}"})
      sdb.put_attributes("PriamProperties", "#{node['cassandra']['priam_clustername']}.priam.multiregion.enable", {"appId" => "#{node['cassandra']['priam_clustername']}", "property" => "priam.multiregion.enable", "value" => "#{node['cassandra']['priam_multiregion_enable']}"})
      sdb.put_attributes("PriamProperties", "#{node['cassandra']['priam_clustername']}.priam.zones.available", {"appId" => "#{node['cassandra']['priam_clustername']}", "property" => "priam.zones.available", "value" => "#{node['cassandra']['priam_zones_available']}"})
      sdb.put_attributes("PriamProperties", "#{node['cassandra']['priam_clustername']}.priam.data.location", {"appId" => "#{node['cassandra']['priam_clustername']}", "property" => "priam.data.location", "value" => "#{node['cassandra']['priam_data_location']}"})
      sdb.put_attributes("PriamProperties", "#{node['cassandra']['priam_clustername']}.priam.cache.location", {"appId" => "#{node['cassandra']['priam_clustername']}", "property" => "priam.cache.location", "value" => "#{node['cassandra']['priam_cache_location']}"})
      sdb.put_attributes("PriamProperties", "#{node['cassandra']['priam_clustername']}.priam.commitlog.location", {"appId" => "#{node['cassandra']['priam_clustername']}", "property" => "priam.commitlog.location", "value" => "#{node['cassandra']['priam_commitlog_location']}"})
      sdb.put_attributes("PriamProperties", "#{node['cassandra']['priam_clustername']}.priam.cass.home", {"appId" => "#{node['cassandra']['priam_clustername']}", "property" => "priam.cass.home", "value" => "#{node['cassandra']['priam_cass_home']}"})
      sdb.put_attributes("PriamProperties", "#{node['cassandra']['priam_clustername']}.priam.cass.startscript", {"appId" => "#{node['cassandra']['priam_clustername']}", "property" => "priam.cass.startscript", "value" => "#{node['cassandra']['priam_cass_startscript']}"})
      sdb.put_attributes("PriamProperties", "#{node['cassandra']['priam_clustername']}.priam.cass.stopscript", {"appId" => "#{node['cassandra']['priam_clustername']}", "property" => "priam.cass.stopscript", "value" => "#{node['cassandra']['priam_cass_stopscript']}"})
      sdb.put_attributes("PriamProperties", "#{node['cassandra']['priam_clustername']}.priam.upload.throttle", {"appId" => "#{node['cassandra']['priam_clustername']}", "property" => "priam.upload.throttle", "value" => "#{node['cassandra']['priam_upload_throttle']}"})

  end
  action :create
end

end
##########################
