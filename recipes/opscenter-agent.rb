log "Installing Opscenter Agent"

# Install Agent

# Download Agent from Leader
log "Downloading Agent from http://#{$LEADERIPADDRESS}/agent.tar.gz"
remote_file "#{Chef::Config[:file_cache_path]}/#{$LEADERIPADDRESS}-opscenter-#{node[:cassandra][:opscenter][:version]}-agent.tar.gz" do
  source "http://#{$LEADERIPADDRESS}/agent.tar.gz"
  mode "0644"
  action :create_if_missing
end

# Install the Agent according to the Documentation - but clear out the old address.yaml in case there is an update, in case the server changed.
bash "Opscenter Agent Installation" do
  code <<-EOH
  cd /tmp/
  tar zxvf #{Chef::Config[:file_cache_path]}/#{$LEADERIPADDRESS}-opscenter-#{node[:cassandra][:opscenter][:version]}-agent.tar.gz
  cd agent
  ./bin/install_agent.sh opscenter-agent.deb #{$LEADERIPADDRESS}
  EOH
  not_if "dpkg -l opscenter-agent | grep #{node[:cassandra][:opscenter][:version]} && grep #{$LEADERIPADDRESS} /var/lib/opscenter-agent/conf/address.yaml"
end

# opscenter server configuration
template "/var/lib/opscenter-agent/conf/address.yaml" do
  variables :LEADERIPADDRESS => $LEADERIPADDRESS
  source "address.yaml.erb"
  mode      "0644"
  notifies :restart, "service[opscenter-agent]", :immediately
end

# The install script starts it but we force it anyway here
service "opscenter-agent" do
  action :start
end
