# cassandra performance optimizations, based on Datastax best practices

# allow cassandra more memory and more open filehandles
file "/etc/security/limits.d/cassandra.conf" do
  mode    0644
  content <<-EOF
#{node[:cassandra][:user]} soft as unlimited
#{node[:cassandra][:user]} hard as unlimited
root soft as unlimited
root hard as unlimited
#{node[:cassandra][:user]} soft memlock unlimited
#{node[:cassandra][:user]} hard memlock unlimited
root soft memlock unlimited
root hard memlock unlimited
#{node[:cassandra][:user]} soft nofile 32768
#{node[:cassandra][:user]} hard nofile 32768
root soft nofile 32768
root hard nofile 32768
EOF
end

# increase the maximum number of memory map areas a process may have
# http://kernel.org/doc/Documentation/sysctl/vm.txt
file "/proc/sys/vm/max_map_count" do
  content "131072"
  backup false
end
