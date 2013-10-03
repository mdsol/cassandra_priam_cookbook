maintainer       "Medidata Solutions, Inc."
maintainer_email "cookbooks@mdsol.com"
license          "Apache 2.0"
description      "Installs Priam-managed Cassandra 1.2 along with Oracle Java and Datastax OpsCenter"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version "0.0.2"

depends "runit"
depends "nginx_proxy" # For DataStax OpsCenter
