# Two packages needed for the Agent to work - all nodes run the Agent, including the Master, in our case.

# required for IO stat reporting
package "sysstat"
# required for opscenter agent connectivity
package "libssl0.9.8"

# A simplistic leadership election
# This search returns all other nodes sharing the unique? role
peers = search(:node, "roles:#{node[:roles].first}" )
# Leader is elected based on lowest numeric hostname
leader = peers.sort{|a,b| a.name <=> b.name}.first

# set some global vars to be used by this and the agent recipe
$leader_name = leader.name
$leader_ipaddress = leader.ipaddress
$leader_ec2_public_hostname = leader.ec2.public_hostname

# Some reporting on the election
log "Opscenter LeaderElection: #{node[:roles].first} Leader is : #{leader_name} #{leader_ec2_public_hostname} #{leader_ipaddress} "

if (node.name == leader.name)
  # leader installs both recipes
  include_recipe "priam-cassandra::opscenter-server"
  include_recipe "priam-cassandra::opscenter-agent"
else 
  # followers install just the agent recipe
  include_recipe "priam-cassandra::opscenter-agent"
end

