Description
===========

This cookbook exists to achieve a deployment of a Priam [1] Managed Cassandra [2] Cluster Deployment.

This cookbook creates the necessary SimpleDB databases [3] to manage the deployment along with some Priam/Cassandra configuration properties [4] managed via chef attributes.

This cookbook also includes Datastax OpsCentre [2] which provides a monitoring dashboard.

This cookbook installs an Oracle JRE and the JNA package.

Special Notes: This cookbook and the software it deploys are only designed to work under AWS with Autoscaling Groups.

See [Priam][1] for more details.

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


Recipes
=======
TODO: List recipes and their usage here.


Usage
=====
TODO: List usage examples here.

Development
===========

License and Authors
===================

* Author: Alex Trull <atrull@mdsol.com>
* Author: Benton Roberts <broberts@mdsol.com>

Copyright: 2013–2013 Medidata Solutions, Inc.
