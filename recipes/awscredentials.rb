# AWS credentials for Priam
template "/etc/awscredential.properties" do
  source "awscredential.properties.erb"
  owner     "#{node[:tomcat][:user]}"
  group     "#{node[:tomcat][:user]}"
  mode      "0640"
end

