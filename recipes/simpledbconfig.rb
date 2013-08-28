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
      sdb.put_attributes("PriamProperties", "#{node['cassandra']['priam_clustername']}.priam.data.location", {"appId" => "#{node['cassandra']['priam_clustername']}", "property" => "priam.data.location", "value" => "#{node['cassandra']['priam_data_location']}"})
      sdb.put_attributes("PriamProperties", "#{node['cassandra']['priam_clustername']}.priam.cache.location", {"appId" => "#{node['cassandra']['priam_clustername']}", "property" => "priam.cache.location", "value" => "#{node['cassandra']['priam_cache_location']}"})
      sdb.put_attributes("PriamProperties", "#{node['cassandra']['priam_clustername']}.priam.commitlog.location", {"appId" => "#{node['cassandra']['priam_clustername']}", "property" => "priam.commitlog.location", "value" => "#{node['cassandra']['priam_commitlog_location']}"})
      sdb.put_attributes("PriamProperties", "#{node['cassandra']['priam_clustername']}.priam.cass.home", {"appId" => "#{node['cassandra']['priam_clustername']}", "property" => "priam.cass.home", "value" => "#{node['cassandra']['priam_cass_home']}"})
      sdb.put_attributes("PriamProperties", "#{node['cassandra']['priam_clustername']}.priam.cass.startscript", {"appId" => "#{node['cassandra']['priam_clustername']}", "property" => "priam.cass.startscript", "value" => "#{node['cassandra']['priam_cass_startscript']}"})
      sdb.put_attributes("PriamProperties", "#{node['cassandra']['priam_clustername']}.priam.cass.stopscript", {"appId" => "#{node['cassandra']['priam_clustername']}", "property" => "priam.cass.stopscript", "value" => "#{node['cassandra']['priam_cass_stopscript']}"})

  end
  action :create
end