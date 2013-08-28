# Various Install attributes
default[:cassandra][:aws][:access_key_id] = nil
default[:cassandra][:aws][:secret_access_key] = nil
default[:cassandra][:user] = "cassandra"
default[:cassandra][:log_dir] = "/var/log/cassandra" # where it this set or used ?
# datastax cassandra comes prefixed dsc-cassandra - modify as necessary for your needs
default[:cassandra][:nameprefix] = "dsc-cassandra"
default[:cassandra][:parentdir] = "/opt"
default[:cassandra][:opscenter_home] = "#{node[:cassandra][:parentdir]}/opscenter"

# Tomcat defaults for Ubuntu - these are needed by Priam
default[:tomcat][:webappsroot] = "/var/lib/tomcat7/webapps"
default[:tomcat][:packagename] = "tomcat7"
default[:tomcat][:user] = "tomcat7"

# These will be fed into SimpleDB for Priam's Configuration which in turn generates Cassandra's configuration
# priam_clustername MUST match the autoscaling group name in order to be used
# priam_clustername is effectively the reference to the correct set of SimpleDB Configuration
default[:cassandra][:priam_clustername] = "SET_ME_PLEASE"
default[:cassandra][:priam_s3_bucket] = "YOURORG-ENVIRONMENT-cassandra-backup"
default[:cassandra][:priam_s3_base_dir] = "cassandra_backups"
default[:cassandra][:priam_cass_home] = "#{node[:cassandra][:parentdir]}/cassandra"
default[:cassandra][:priam_data_location] = "/mnt/cassandra/data"
default[:cassandra][:priam_cache_location] = "/mnt/cassandra/saved_caches"
default[:cassandra][:priam_commitlog_location] = "/mnt/cassandra/commitlog"
default[:cassandra][:priam_cass_startscript] = "/etc/init.d/cassandra start"
default[:cassandra][:priam_cass_stopscript] = "/etc/init.d/cassandra stop"

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
default[:cassandra][:priam_version] = "1.2.17"
default[:cassandra][:priam_web_war][:src_url] = "#{SRC}/priam/#{node['cassandra']['priam_version']}/priam-web-#{node['cassandra']['priam_version']}.war"
default[:cassandra][:priam_web_war][:checksum] = "fbc1779f9cff9a8e3a4933000a9f2784c2037519f0e1f2777ae39dfee9d831a0"
default[:cassandra][:priam_cass_extensions_jar][:src_url] = "#{SRC}/priam/#{node['cassandra']['priam_version']}/priam-cass-extensions-#{node['cassandra']['priam_version']}.jar"
default[:cassandra][:priam_cass_extensions_jar][:checksum] = "f5cbee81dd885d07c5e3aff9b45de5a8cf9674eecc4a8af0bcd736a9c86afdab"

# For DataStax OpsCenter
include_attribute "nginx_proxy"
default[:nginx_proxy][:http_port] = 8888
default[:nginx_proxy][:https_port] = 8888