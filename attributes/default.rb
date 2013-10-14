###
# Various Install attributes

# We will attempt to get AWS credentials from a databag - the attributes of which are below
# These variables stolen from the EBS cookbook https://raw.github.com/albertsj1/chef-ebs/master/attributes/default.rb
default[:cassandra][:aws][:databag] = "credentials"
default[:cassandra][:aws][:item] = "aws"
# IDs inside the item to use
default[:cassandra][:aws][:aki] = "aws_access_key_id"
default[:cassandra][:aws][:sak] = "aws_secret_access_key"
default[:cassandra][:aws][:encrypted] = true

# We will create this user
default[:cassandra][:user] = "cassandra"
default[:cassandra][:log_dir] = "/var/log/cassandra"

# Datastax's build of cassandra comes prefixed dsc-cassandra - modify as necessary for your needs
default[:cassandra][:nameprefix] = "dsc-cassandra"

# We will try to install all software to this path
default[:cassandra][:parentdir] = "/opt"

# Fog gem version - used to write to SimpleDB
default[:cassandra][:fog][:version] = "1.9.0"

# This package name may be different on untested distributions so we make it an attribute
default[:cassandra][:jnapackagename] = "libjna-java"

###
# Start of SimpleDB Config Attributes

# The following variables are used to feed SimpleDB
# Priam configures Cassandra and itself using these variables

# priam_clustername MUST match the autoscaling group name (before the dash) in order to be used i.e. project_stage_db-useast1 == cluster_name-ec2region
# priam_clustername is effectively the reference to the correct set of SimpleDB Configuration
# we will attempt to set this based on the role name, which should match the asg name. If your role does not match the name then this MUST be set.
default[:cassandra][:priam_clustername] = "SET_ME_PLEASE"

# We won't set this if it isn't true  - set it to "true" to enable enable multiregion
default[:cassandra][:priam_multiregion_enable] = nil

# This is the default single-region snitch - set it to "org.apache.cassandra.locator.Ec2MultiRegionSnitch" for multiregion
default[:cassandra][:priam_endpoint_snitch] = "org.apache.cassandra.locator.Ec2Snitch"

# This must be set for all multiregion and any single region deployments outside the first three (abc) AZs/datacenters in a region
# i.e. "us-east-1a,us-east-1c,us-west-1a,us-west-1b,us-west-1c" or "us-east-1c,us-east-1d"
# If not set it will not be applied
default[:cassandra][:priam_zones_available] = nil

# If you want backups, set this variable to the name of an s3 bucket you have created.
default[:cassandra][:priam_s3_bucket] = "SET_ME_PLEASE"

# The rest - relatively self-explanatory variables, safe defaults for ec2 deployment where /mnt is a large block device.
default[:cassandra][:priam_s3_base_dir] = "cassandra_backups"
default[:cassandra][:priam_cass_home] = "#{node[:cassandra][:parentdir]}/cassandra"
default[:cassandra][:priam_data_location] = "/mnt/cassandra/data"
default[:cassandra][:priam_cache_location] = "/mnt/cassandra/saved_caches"
default[:cassandra][:priam_commitlog_location] = "/mnt/cassandra/commitlog"
default[:cassandra][:priam_cass_startscript] = "/etc/init.d/cassandra start"
default[:cassandra][:priam_cass_stopscript] = "/etc/init.d/cassandra stop"
default[:cassandra][:priam_upload_throttle] = "5"

###
# Where to get the software..

# Where to get Cassandra from: Directly from Datastax
default[:cassandra][:version] = "1.2.10"
default[:cassandra][:src_url] = "http://downloads.datastax.com/community/#{node['cassandra']['nameprefix']}-#{node['cassandra']['version']}-bin.tar.gz"
default[:cassandra][:checksum] = "c731c8e2bc84769f884f423fb839ab3205279972b842ab37fdace49ef511e544"

# Priam Build Sources
# If someone starts providing builds of Priam - this would be good.
# Source files are in a Medidata-controlled S3 bucket with no authentication
SRC = 'http://dl.imedidata.net/cassandra'
default[:cassandra][:priam_version] = "1.2.17"
default[:cassandra][:priam_web_war][:src_url] = "#{SRC}/priam/#{node['cassandra']['priam_version']}/priam-web-#{node['cassandra']['priam_version']}.war"
default[:cassandra][:priam_web_war][:checksum] = "fbc1779f9cff9a8e3a4933000a9f2784c2037519f0e1f2777ae39dfee9d831a0"
default[:cassandra][:priam_cass_extensions_jar][:src_url] = "#{SRC}/priam/#{node['cassandra']['priam_version']}/priam-cass-extensions-#{node['cassandra']['priam_version']}.jar"
default[:cassandra][:priam_cass_extensions_jar][:checksum] = "f5cbee81dd885d07c5e3aff9b45de5a8cf9674eecc4a8af0bcd736a9c86afdab"

