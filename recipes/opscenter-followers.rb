# This search returns all other nodes sharing the unique? role
peers = search(:node, "roles:#{node[:roles].first}" )
leader = peers.sort{|a,b| a.name <=> b.name}.first

# Install Agent

remote_file "#{Chef::Config[:file_cache_path]}/agent.tar.gz" do
  source "http://#{leader.ec2.public_hostname}/agent.tar.gz"
  mode "0644"
end

bash "Opscenter Agent Installation" do
  code <<-EOH
  cd /tmp/
  tar zxvf #{Chef::Config[:file_cache_path]}/agent.tar.gz
  cd agent
  ./bin/install_agent.sh -s opscenter-agent.deb #{leader.ec2.public_hostname}
  EOH
  not_if { ::File.exists?("/var/lib/opscenter-agent/conf/address.yaml") }
end

service "opscenter-agent" do
  action :start
end
