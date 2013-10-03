# setup java - this ought to be replaced with the java cookbook
include_recipe "priam-cassandra::oraclejava6"

# setup up performance optimizations
include_recipe "priam-cassandra::optimizations"

# install tomcat
package node[:tomcat][:packagename] do
  action :install
end

# some external dependencies
include_recipe "runit"

# install cassandra server
include_recipe "priam-cassandra::cassandra-installation"

# install priam cluster management
include_recipe "priam-cassandra::priam"

# start cassandra server
include_recipe "priam-cassandra::cassandra-startup"

# install opscenter cluster monitoring
include_recipe "priam-cassandra::opscenter"

