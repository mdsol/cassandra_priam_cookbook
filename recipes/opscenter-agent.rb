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

# Install the Agent according to the Documentation - but clear out the old address.yaml in case there is an update, in case the server changed.
bash "Opscenter Agent Installation" do
  code <<-EOH
  cd /tmp/
  tar zxvf #{Chef::Config[:file_cache_path]}/#{leader.ec2.public_hostname}-opscenter-#{node[:cassandra][:opscenter][:version]}-agent.tar.gz
  cd agent
  ./bin/install_agent.sh opscenter-agent.deb #{leader.ipaddress}
  EOH
  not_if "dpkg -l opscenter-agent | grep #{node[:cassandra][:opscenter][:version]} && grep #{leader.ipaddress} /var/lib/opscenter-agent/conf/address.yaml"
end

# opscenter server configuration
template "/var/lib/opscenter-agent/conf/address.yaml" do
  variables :leader_ipaddress => leader.ipaddress
  source "address.yaml.erb"
  mode      "0644"
  notifies :restart, "service[opscenter-agent]", :immediately
end

# The install script starts it but we force it anyway here
service "opscenter-agent" do
  action :start
end
