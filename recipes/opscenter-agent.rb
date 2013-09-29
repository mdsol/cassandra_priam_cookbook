log "Installing Opscenter Agent"

# This search returns all other nodes sharing the unique? role
peers = search(:node, "roles:#{node[:roles].first}" )
# Leader is elected based on lowest numeric hostname
leader = peers.sort{|a,b| a.name <=> b.name}.first

# Install Agent

# Download Agent from Leader
log "Downloading Agent from http://#{leader.ec2.public_hostname}/agent.tar.gz"
remote_file "#{Chef::Config[:file_cache_path]}/#{leader.ec2.public_hostname}-opscenter-#{node[:cassandra][:opscenter][:version]}-agent.tar.gz" do
  source "http://#{leader.ec2.public_hostname}/agent.tar.gz"
  mode "0644"
end

# Install the Agent according to the Documentation
bash "Opscenter Agent Installation" do
  code <<-EOH
  cd /tmp/
  tar zxvf #{Chef::Config[:file_cache_path]}/#{leader.ec2.public_hostname}-opscenter-#{node[:cassandra][:opscenter][:version]}-agent.tar.gz
  cd agent
  ./bin/install_agent.sh opscenter-agent.deb #{leader.ec2.public_hostname}
  EOH
  not_if "dpkg -l opscenter-agent | grep #{node[:cassandra][:opscenter][:version]}"
  not_if "grep #{leader.ec2.public_hostname} /var/lib/opscenter-agent/conf/address.yaml"
end

# The install script starts it but we force it anyway here
service "opscenter-agent" do
  action :start
end
