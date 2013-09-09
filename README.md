Description
===========

This cookbook exists to achieve a deployment of a Priam [1] Managed Cassandra [2] Cluster.

This cookbook creates the necessary SimpleDB databases [3] to manage the deployment along with some Priam/Cassandra configuration properties [4] managed via chef attributes.

This cookbook also includes Datastax OpsCentre [2] which provides a monitoring dashboard.

This cookbook installs an Oracle JRE and the JNA package.

Special Notes: This cookbook and the software it deploys are only designed to work under AWS EC2 with Autoscaling and SimpleDB.
               You should check that the credentials you provide have the necessary accesss to use the relevant AWS services.

See [Priam][1] for a descriptiong of the software.

[1]: https://github.com/Netflix/Priam
[2]: http://planetcassandra.org/Download/DataStaxCommunityEdition
[3]: http://aws.amazon.com/simpledb/
[4]: https://github.com/Netflix/Priam/wiki/Properties & https://github.com/Netflix/Priam/wiki/1.2

Requirements
============
Chef 11.0.0+
Amazon AWS
Amazon Autoscaling
Amazon SimpleDB

## Platform

* Ubuntu 10.04+

Attributes
==========

See the contents of attributes/default.rb

Recipes
=======

awscredentials.rb
cassandra.rb
default.rb
opscenter.rb
optimizations.rb
oraclejava6.rb
priam.rb
runit.rb
simpledbconfig.rb
tomcat.rb

Usage
=====

To deploy Priam-driven Cassandra Clusters

Development
===========

License and Authors
===================

* Author: Alex Trull <atrull@mdsol.com>
* Author: Benton Roberts <broberts@mdsol.com>

Copyright: 2013–2013 Medidata Solutions, Inc.
