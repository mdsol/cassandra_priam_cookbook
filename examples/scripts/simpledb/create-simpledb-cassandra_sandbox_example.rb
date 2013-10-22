#!/usr/bin/env ruby
require 'fog'

keys = Hash[File.read("./awscredential.properties.example").split.map{|e| e.split("=") }]
sdb = Fog::AWS::SimpleDB.new(:aws_access_key_id => keys["AWSACCESSID"], :aws_secret_access_key => keys["AWSKEY"])

sdb.create_domain("InstanceIdentity")
sdb.create_domain("PriamProperties")

sdb.put_attributes("PriamProperties", "cassandra_sandbox_example.priam.s3.bucket", {"appId" => "cassandra_sandbox_example", "property" => "priam.s3.bucket", "value" => "ourspecialbucket"})
sdb.put_attributes("PriamProperties", "cassandra_sandbox_example.priam.s3.base_dir", {"appId" => "cassandra_sandbox_example", "property" => "priam.s3.base_dir", "value" => "cassandra_backups"})
sdb.put_attributes("PriamProperties", "cassandra_sandbox_example.priam.clustername", {"appId" => "cassandra_sandbox_example", "property" => "priam.clustername", "value" => "cassandra_sandbox_example"})
sdb.put_attributes("PriamProperties", "cassandra_sandbox_example.priam.data.location", {"appId" => "cassandra_sandbox_example", "property" => "priam.data.location", "value" => "/mnt/lib/cassandra/data"})
sdb.put_attributes("PriamProperties", "cassandra_sandbox_example.priam.cache.location", {"appId" => "cassandra_sandbox_example", "property" => "priam.cache.location", "value" => "/mnt/lib/cassandra/saved_caches"})
sdb.put_attributes("PriamProperties", "cassandra_sandbox_example.priam.commitlog.location", {"appId" => "cassandra_sandbox_example", "property" => "priam.commitlog.location", "value" => "/mnt/lib/cassandra/commitlog"})
sdb.put_attributes("PriamProperties", "cassandra_sandbox_example.priam.cass.home", {"appId" => "cassandra_sandbox_example", "property" => "priam.cass.home", "value" => "/mnt/cassandra"})
sdb.put_attributes("PriamProperties", "cassandra_sandbox_example.priam.cass.startscript", {"appId" => "cassandra_sandbox_example", "property" => "priam.cass.startscript", "value" => "/etc/init.d/cassandra start"})
sdb.put_attributes("PriamProperties", "cassandra_sandbox_example.priam.cass.stopscript", {"appId" => "cassandra_sandbox_example", "property" => "priam.cass.stopscript", "value" => "/etc/init.d/cassandra stop"})

