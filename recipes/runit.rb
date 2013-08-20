include_recipe "runit"

# fire up cassandra 
runit_service "cassandra" do
  supports  :restart => false
  env({ 'HOME' => node[:cassandra][:priam_cass_home] })
end
