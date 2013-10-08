# AWS credentials for Priam
template "/etc/awscredential.properties" do
  source "awscredential.properties.erb"
  owner     "#{node[:tomcat][:user]}"
  group     "#{node[:tomcat][:group]}"
  mode      "0640"
  variables ({
    :access_key_id => node[:cassandra][:aws][:access_key_id],
    :secret_access_key => node[:cassandra][:aws][:secret_access_key]
  })
end

