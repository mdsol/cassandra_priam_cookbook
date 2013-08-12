# We need to rework these vars
HOME      = node[:cassandra][:home]
DATA_DIR  = node[:cassandra][:data_dir]
LOG_DIR   = node[:cassandra][:log_dir]
CLUSTER   = node[:cassandra][:cluster] || (
              node[:mdsol][:project] && node[:mdsol][:environment] ?
                "#{node[:mdsol][:project]}-#{node[:mdsol][:environment]}" :
                'Test Cluster')

# here are the variables for all the templates
TEMPLATE_VARS = {
  :home               => HOME,
  :data_dir           => DATA_DIR,
  :log_dir            => LOG_DIR,
  :cluster_name       => CLUSTER,
}

# setup java
# this should be replaced with the java cookbook
include_recipe "priam-cassandra::oraclejava6"

# install cassandra database server
include_recipe "priam-cassandra::cassandra"

# install priam cluster management
include_recipe "priam-cassandra::priam"

# install opscenter cluster monitoring
include_recipe "priam-cassandra::opscenter"

# setup agents for the above (priam and opscenter)
include_recipe "priam-cassandra::agents"

# setup Priam/Cassandra configuration in Amazon SDB
include_recipe "priam-cassandra::simpledbconfig"

# setup up performance optimizations
include_recipe "priam-cassandra::optimizations"

# startup
include_recipe "priam-cassandra::startup"
