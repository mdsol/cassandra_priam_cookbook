# setup java - this ought to be replaced with the java cookbook
include_recipe "cassandra-priam::oraclejava6"

# setup up performance optimizations
include_recipe "cassandra-priam::optimizations"

# install tomcat
package node[:tomcat][:packagename] do
  action :install
end

# some external dependencies
include_recipe "runit"

# install cassandra server
include_recipe "cassandra-priam::cassandra-installation"

# install priam cluster management
include_recipe "cassandra-priam::priam"

# start cassandra server
include_recipe "cassandra-priam::cassandra-startup"

# install opscenter cluster monitoring
include_recipe "cassandra-opscenter"

