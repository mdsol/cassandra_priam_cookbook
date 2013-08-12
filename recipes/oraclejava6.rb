# installs Oracle Java 6 from Medidata source S3 bucket
SRC_URL = "http://cloudteam-packages.s3.amazonaws.com/java/jre-6u38-linux-x64.bin"
# JNA_SRC is needed for Ubuntu 10.04 only
JNA_SRC = "http://cloudteam-packages.s3.amazonaws.com/java/jna-3.5.1.jar"
JAVA_DIR = "/usr/java/latest/jre1.6.0_38"

directory JAVA_DIR do
  recursive true
end

# download Java installer
local_installer = "#{::File.dirname JAVA_DIR}/#{::File.basename SRC_URL}"
remote_file local_installer do
  source  SRC_URL
  mode    0755
  not_if  { File.exists? local_installer }
end

# install Oracle Java
execute "install Oracle Java 6" do
  command   "./#{::File.basename local_installer}"
  creates   "#{JAVA_DIR}/bin/java"
  cwd       ::File.dirname local_installer
end
bash "set java altenatives" do
  code <<-EOH
    update-alternatives --install "/usr/bin/java" "java" "#{JAVA_DIR}/bin/java" 1
    update-alternatives --install "/usr/bin/javaws" "javaws" "#{JAVA_DIR}/bin/javaws" 1
    update-alternatives --set java #{JAVA_DIR}/bin/java
  EOH
  action :nothing
  subscribes :run, resources("execute[install Oracle Java 6]"), :immediately
end

# install Java Native Interface - this is complicated for Ubuntu 10.04
if node[:platform_version].to_f == 10.04
  local_jar = "#{::File.dirname JAVA_DIR}/#{::File.basename JNA_SRC}"
  remote_file local_jar do
    source  JNA_SRC
    mode    0644
    not_if  { File.exists? local_jar }
  end
  directory "/usr/share/java"
  link "/usr/share/java/jna.jar" do
    to        local_jar
    link_type :hard
  end
else # (it's much easier on later versions of Ubuntu)
  package "libjna-java"
end
