# required for IO stat reporting
package "sysstat"

# required for opscenter agent connectivity
package "libssl0.9.8"

# force the node to save so we find ourselves in search
node.save

# this does not mean this node will show up in a search yet, however.
log "LeaderElection: Roles : #{node[:roles].first}"

# This search returns all other nodes sharing the unique? role
peers = search(:node, "roles:#{node[:roles].first}" )
leader = peers.sort{|a,b| a.name <=> b.name}.first

# spam block - can be removed
followers = peers.reject{|p| p.name == leader.name}
peershostnames = peers.collect {|n| n[:ec2][:public_hostname]}
followershostnames = followers.collect {|n| n[:ec2][:public_hostname]}
log "LeaderElection: #{node[:roles].first} Servers are : #{peershostnames.join ' '}"
log "LeaderElection: #{node[:roles].first} Followers are : #{followershostnames.join ' '}"
log "LeaderElection: #{node[:roles].first} Leader is : #{leader.ec2.public_hostname}"

if (node.name == leader.name)
  log "LeaderElection: I am leader"
  include_recipe "priam-cassandra::opscenter-leader"
  include_recipe "priam-cassandra::opscenter-followers"
else 
  log "LeaderElection: I am follower"
  include_recipe "priam-cassandra::opscenter-followers"
end

