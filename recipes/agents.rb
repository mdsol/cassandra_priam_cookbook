# pull in the original cassandra.in.sh from where it lies in the cassandra home
# concatenate the Priam agent onto the end of the file
# copy the file where it will be picked up
# sadly doing this a chef-way is too bothersome compared to shellscript

bash "Setup Agent in Cassandra Include File" do
  user node[:cassandra][:user]
  cwd "/"
  code <<-EOH
  cp #{node[:cassandra][:priam_cass_home]}/bin/cassandra.in.sh /tmp
  echo "export JVM_OPTS=\"-javaagent:\$CASSANDRA_HOME/lib/priam-cass-extensions-#{node[:cassandra][:priam_version]}.jar\"" >> /tmp/cassandra.in.sh
  cp /tmp/cassandra.in.sh  #{node[:cassandra][:priam_cass_home]}/
  EOH
end

