# POSIX user
user "#{node[:cassandra][:user]}" do
  system    true
  home      node[:cassandra][:priam_cass_home]
  gid       node[:tomcat][:user]
  shell     "/bin/sh"
end

# Create the Data/Cache/Commitlog/Log Directories
[ node[:cassandra][:priam_data_location],
  node[:cassandra][:priam_cache_location],
  node[:cassandra][:priam_commitlog_location],
  node[:cassandra][:log_dir]  
].each do |dir|
  directory dir do
    owner     "#{node[:cassandra][:user]}"
    group     "#{node[:tomcat][:user]}"
    mode      0770
    recursive true
  end
end

# download source
src_url = node[:cassandra][:src_url]
local_archive = "#{Chef::Config[:file_cache_path]}/#{::File.basename src_url}"
remote_file local_archive do
  source  src_url
  mode    0644
  not_if  { File.exists? local_archive }
  checksum node[:cassandra][:checksum]
end

VERSION_DIR = "#{node[:cassandra][:parentdir]}/#{node[:cassandra][:nameprefix]}-#{node[:cassandra][:version]}"

# create the target directory
directory VERSION_DIR do
  owner     "#{node[:cassandra][:user]}"
  group     "#{node[:tomcat][:user]}"
  mode      0775
  recursive true
end

# unpack to the versioned directory first
execute "unpack #{local_archive}" do
  command   "tar --strip-components 1 --no-same-owner -xzf #{local_archive}"
  creates   "#{VERSION_DIR}/bin/cassandra"
  user      "#{node[:cassandra][:user]}"
  group     "#{node[:tomcat][:user]}"
  cwd       VERSION_DIR
end

# link the priam_cass_home to the version directory
link node[:cassandra][:priam_cass_home] do
  to        VERSION_DIR
  owner     "#{node[:cassandra][:user]}"
  group     "#{node[:tomcat][:user]}"
end

# link in Java Native interface, if found
link "#{node[:cassandra][:priam_cass_home]}/lib/jna.jar" do
  to "/usr/share/java/jna.jar"
  only_if { ::File.exists? "/usr/share/java/jna.jar" }
end

# create a runit service for cassandra, but do not start it
# this uses templates which abstract the interesting parts.
# Priam starts cassandra when it starts up.
runit_service "cassandra" do
  supports  :restart => true
  action :enable
  env({ 'HOME' => node[:cassandra][:priam_cass_home] })
end
