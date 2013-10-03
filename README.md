Description
===========

This cookbook exists to achieve a deployment of a [Priam][1] Managed [Cassandra][2] Cluster.

This cookbook creates the necessary [SimpleDB][3] databases to manage the deployment along with some Priam/Cassandra configuration [Properties][4] managed via chef attributes.

This cookbook installs an Oracle JRE and the JNA package.

Special Notes: This cookbook and the software it deploys are only designed to work under AWS EC2 with Autoscaling and SimpleDB.
               You should check that the credentials you provide have the necessary accesss to use the relevant AWS services.

[1]: https://github.com/Netflix/Priam
[2]: http://planetcassandra.org/Download/DataStaxCommunityEdition
[3]: http://aws.amazon.com/simpledb/
[4]: https://github.com/Netflix/Priam/wiki/Properties

Requirements
============
Chef 10.16.4+
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

default.rb
awscredentials.rb
cassandra-installation.rb
cassandra-startup.rb
optimizations.rb
oraclejava6.rb
priam.rb
simpledbconfig.rb

Usage
=====

Include cassandra-priam in your runlist.

Development
===========

See the [Github page][5]

[5]: https://github.com/mdsol/cassandra_priam_cookbook

License and Authors
===================

* Author: Alex Trull <atrull@mdsol.com>
* Author: Benton Roberts <broberts@mdsol.com>

Copyright: 2013–2013 Medidata Solutions, Inc.
