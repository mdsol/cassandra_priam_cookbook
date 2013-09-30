# Two packages needed for the Agent to work - all nodes run the Agent.

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
# Leader is elected based on lowest numeric hostname
leader = peers.sort{|a,b| a.name <=> b.name}.first

# Some reporting on the election
log "LeaderElection: #{node[:roles].first} Leader is : #{leader.ec2.public_hostname}"

if (node.name == leader.name)
  # leader installs both recipes
  include_recipe "priam-cassandra::opscenter-server"
  include_recipe "priam-cassandra::opscenter-agent"
else 
  # followers install just the agent recipe
  include_recipe "priam-cassandra::opscenter-agent"
  # we don't clean up former opscenter servers because they may contain interesting data
  # include_recipe "priam-cassandra::opscenter-remove-server" 
end

