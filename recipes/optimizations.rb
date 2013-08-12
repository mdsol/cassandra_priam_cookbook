# cassandra performance optimizations, based on Datastax best practices

# allow cassandra more memory and more open filehandles
file "/etc/security/limits.d/cassandra.conf" do
  mode    0644
  content <<-EOF
cassandra soft as unlimited
cassandra hard as unlimited
root soft as unlimited
root hard as unlimited
cassandra soft memlock unlimited
cassandra hard memlock unlimited
root soft memlock unlimited
root hard memlock unlimited
cassandra soft nofile 32768
cassandra hard nofile 32768
root soft nofile 32768
root hard nofile 32768
EOF
end

# increase the maximum number of memory map areas a process may have
# http://kernel.org/doc/Documentation/sysctl/vm.txt
file "/proc/sys/vm/max_map_count" do
  content "131072"
end
