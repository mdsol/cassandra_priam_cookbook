# fire up cassandra by creating a runit service for it - this uses templates which abstract the interesting parts.
runit_service "cassandra" do
  supports  :restart => false
  env({ 'HOME' => node[:cassandra][:priam_cass_home] })
  only_if "grep #{node[:cassandra][:priam_clustername]} #{node[:cassandra][:priam_cass_home]}/etc/cassandra.yaml"
end
