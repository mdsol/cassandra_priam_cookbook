# some external dependencies
include_recipe "runit"
include_recipe "java"

# setup up performance optimizations
include_recipe "cassandra-priam::optimizations"

# install tomcat
package node[:tomcat][:packagename]

# install JNA
package "libjna-java"

# install cassandra server
include_recipe "cassandra-priam::cassandra"

# aws credentials - needed to apply simpledb config and used by Priam for various functions.
include_recipe "cassandra-priam::awscredentials"

## Simplistic leader election
node.save
peers = search(:node, "roles:#{node[:roles].first}" )
leader = peers.sort{|a,b| a.uptime_seconds <=> b.uptime_seconds}.last || node    # the "or" covers the case where node is the first db

# Some reporting on the election
log "cassandra-priam LeaderElection: #{node[:roles].first} Leader is : #{$LEADERNAME} #{$LEADEREC2PUBLICHOSTNAME} #{$LEADERIPADDRESS} "

if (node.name == leader.name)
  # Apply the Priam/Cassandra configuration to Amazon SDB
  include_recipe "cassandra-priam::simpledbconfig"
end

# install priam cluster management - this starts Cassandra
include_recipe "cassandra-priam::priam"

