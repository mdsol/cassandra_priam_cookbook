# required for IO stat reporting
package "sysstat"

# required for opscenter agent connectivity
package "libssl0.9.8"

# am I first in fleet ?
# i.e. node with the lowest ip
# this assumes a single role

#priam_cassandra_barrier "opscenter_on_#{node[:roles].first}"

# this does not mean this node will show up in a search yet, however.
log "LeaderElection: Roles : #{node[:roles].first}"

# This search returns all other nodes sharing the unique? role
peers = search(:node, "roles:#{node[:roles].first}" )

leader = peers.sort{|a,b| a.name <=> b.name}.first
followers = peers.reject{|p| p.name == leader.name}

peershostnames = peers.collect {|n| n[:ec2][:public_hostname]}
followershostnames = followers.collect {|n| n[:ec2][:public_hostname]}

log "LeaderElection: #{node[:roles].first} Servers are : #{peershostnames.join ' '}"
log "LeaderElection: #{node[:roles].first} Followers are : #{followershostnames.join ' '}"
log "LeaderElection: #{node[:roles].first} Leader is : #{leader.ec2.public_hostname}"

if (node.name == leader.name)
  log "LeaderElection: I am leader"
  include_recipe "priam-cassandra::opscenter-leader"
  # install agent
  # /opt/opscenter/agent/opscenter-agent.deb
else 
  log "LeaderElection: I am follower"
  #follower code
  # copying file from leader
  log "copying deb from #{leader.name} #{leader.ec2.public_hostname}"
  # install agent
  # /opt/opscenter/agent/opscenter-agent.deb 
end

