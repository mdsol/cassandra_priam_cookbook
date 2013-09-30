# Optional cleanup script 

bash "Cleanup Opscenter Server" do 
  code <<-EOH
  pkill -f start_opscenter.py
  rm -rf /opt/opscenter* 
  EOH
  only_if  "pgrep -f start_opscenter.py"
end

