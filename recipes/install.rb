# some external dependencies
include_recipe "sudo"
include_recipe "runit"
include_recipe "java"
include_recipe "tomcat"

# setup up performance optimizations
include_recipe "cassandra-priam::optimizations"

# install JNA
package node[:cassandra][:jnapackagename]

# install cassandra server
include_recipe "cassandra-priam::cassandra"

# aws credentials - needed to apply simpledb config and used by Priam for various functions.
include_recipe "cassandra-priam::awscredentials"

## Simplistic leader election
node.save
peers = search(:node, "roles:#{node[:roles].first}" )
leader = peers.sort{|a,b| a.name <=> b.name}.first || node # the "or" covers the case where node is the first db

# Some reporting on the election
log "cassandra-opscenter LeaderElection: #{node[:roles].first} Leader is : #{leader.name} #{leader.ec2.public_hostname} #{leader.ipaddress}"

if (node.name == leader.name)
  # Apply the Priam/Cassandra configuration to Amazon SDB
  include_recipe "cassandra-priam::simpledbconfig"
end

# install priam cluster management - this starts Cassandra
include_recipe "cassandra-priam::priam"

