# Priam runs in Tomcat
package node[:tomcat][:packagename]

# AWS credentials for Priam
template "/etc/awscredential.properties" do
  source "awscredential.properties.erb"
end

# Sudo entry to manage cassandra startup/shutdown via Priam
template "/etc/sudoers.d/tomcat" do
  source "tomcatsudo.erb"
end

# Priam's War
src_url = node[:cassandra][:priam_web_war][:src_url]
local_archive = "#{node[:tomcat][:webappsroot]}/Priam.war"
remote_file local_archive do
  source  src_url
  mode    0644
  not_if  { File.exists? local_archive }
  checksum node[:cassandra][:priam_web_war][:checksum]
end

# Priam's agent jar 
src_url = node[:cassandra][:priam_cass_extensions_jar][:src_url]
local_archive = "#{node[:cassandra][:home]}/lib/#{::File.basename src_url}"
remote_file local_archive do
  source  src_url
  mode    0644
  not_if  { File.exists? local_archive }
  checksum node[:cassandra][:priam_cass_extensions_jar][:checksum]
end

