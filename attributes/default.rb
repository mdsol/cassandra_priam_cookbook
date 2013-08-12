# These will be fed into SimpleDB for Priam's Configuration which in turn generates Cassandra's configuration
# priam_clustername MUST match the autoscaling group name in order to be used
# priam_clustername is effectively the reference to the correct set of SimpleDB Configuration
default[:cassandra][:priam_clustername] = "SET_ME_PLEASE"
default[:cassandra][:priam_s3_bucket] = "YOURORG-ENVIRONMENT-cassandra-backup"
default[:cassandra][:priam_s3_base_dir] = "#{node[:cassandra][:priam_clustername]}"
default[:cassandra][:priam_cass_home] = "#{node[:cassandra][:parentdir]}/cassandra"
default[:cassandra][:priam_data_location] = "/mnt/cassandra/data"
default[:cassandra][:priam_cache_location] = "/mnt/cassandra/saved_caches"
default[:cassandra][:priam_commitlog_location] = "/mnt/cassandra/commitlog"
default[:cassandra][:priam_cass_startscript] = "/etc/init.d/cassandra start"
default[:cassandra][:priam_cass_stopscript] = "/etc/init.d/cassandra stop"

# Other attributes
default[:cassandra][:aws][:access_key_id] = nil
default[:cassandra][:aws][:secret_access_key] = nil
default[:cassandra][:user] = "cassandra"
default[:cassandra][:log_dir] = "/var/log/cassandra" # where it this set ?
default[:cassandra][:opscenter_home] = "#{node[:cassandra][:parentdir]}/opscenter"
# datastax cassandra comes prefixed dsc-cassandra - modify as necessary for your needs
default[:cassandra][:nameprefix] = "dsc-cassandra"
default[:cassandra][:parentdir] = "/opt"

# Tomcat defaults for Ubuntu - these are needed by Priam
default[:tomcat][:webappsroot] = "/var/lib/tomcat7/webapps"
default[:tomcat][:packagename] = "tomcat7"
default[:tomcat][:user] = "tomcat7"

# This cookbooks requires a LOT of software to be stored in an http server.
# Source files are in a Medidata-controlled S3 bucket with open http auth
SRC = 'http://cloudteam-packages.s3.amazonaws.com/cassandra'
# you can roll your own as necessary.
# /cassandra/ (cassandra and opscenter files including an extracted agent tar.gz)
# /cassandra/priam/priam-version/ (priam files)
# checksums are sha256 - the default chef remote_file checksum - obviously these need to be modified for later versions of software
default[:cassandra][:version] = "1.2.8"
default[:cassandra][:src_url] = "#{SRC}/#{node['cassandra']['nameprefix']}-#{node['cassandra']['version']}.tar.gz"
default[:cassandra][:checksum] = "f372c380a2639607580f2f14a393c54cc979bfbf630199381278845546fda077"
default[:cassandra][:opscenter][:version] = "3.2.0"
default[:cassandra][:opscenter][:src_url] = "#{SRC}/opscenter-#{node['cassandra']['opscenter']['version']}-free.tar.gz"
default[:cassandra][:opscenter][:checksum] = "64d38d7e0060895993f70428468178b09d498e7531ab0d32f2a7547761a959bd"
default[:cassandra][:priam_version] = "1.2.14-SNAPSHOT"
default[:cassandra][:priam_web_war][:src_url] = "#{SRC}/priam/#{node['cassandra']['priam']['version']}/priam-web-#{node['cassandra']['priam']['version']}.war"
default[:cassandra][:priam_web_war][:checksum] = "fe335743c290e965b3dee7b53f21bf5cd6495b9e1e27ce1dfbb52fced87b242f"
default[:cassandra][:priam_cass_extensions_jar][:src_url] = "#{SRC}/priam/#{node['cassandra']['priam']['version']}/priam-cass-extensions-#{node['cassandra']['priam']['version']}.jar"
default[:cassandra][:priam_cass_extensions_jar][:checksum] = "e0c577b6763829640a11a162a29756dfbbf9c0073f7235c0d18531b837bf6361"

# For DataStax OpsCenter
include_attribute "nginx_proxy"
default[:nginx_proxy][:http_port] = 8888
default[:nginx_proxy][:https_port] = 8888

#### CUTOFF: attributes to be removed I expect or shunted to SDBt

# Cassandra Snitch
# Use Ec2MultiRegionSnitch for multi-region deployments,
default[:cassandra][:snitch] = 'Ec2Snitch'

# Seed hosts
# If this Array attribute is empty, Chef will search for other Cassandra
# nodes with the same cluster name, and use their seed host list.
# Failing that, the node will list itself as a seed
default[:cassandra][:seeds] = Array.new
# The number of seed nodes required before the cluster starts
# Set this to 1 for a standalone cluster
default[:cassandra][:required_seeds] = 2

# (Used for state - do not manipulate directly)
default[:cassandra][:trusted_peers] = Array.new
