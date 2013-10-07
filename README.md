Description
===========

This cookbook exists to achieve a deployment of a [Priam][1] Managed [Cassandra][2] Cluster.

This cookbook elects a leader to create the necessary [SimpleDB][3] databases/configuration entries to manage the deployment along with some Priam/Cassandra configuration [Properties][4] managed via chef attributes.

Priam is a sidecar application that takes care of Cassandra Configuration, Startup, Seeding and Node Replacement, Backups (to s3) and Restoration (from s3). It makes the lifecycle of Cassandra clusters much easier to manage.

This cookbook installs the JNA package.

Special Caveats:

This cookbook and the software it deploys are only designed to work under AWS EC2 with Autoscaling and SimpleDB.

You should check that the credentials you provide have the necessary accesss to use the relevant AWS services.

General Caveats:

The software this cookbook installs has mostly been tested with the Oracle JRE - your mileage may very on other JRE builds. 

Contact Amazon to get your SimpleDB limits increased moderately with your usage.

This cookbook will attempt to configure a cluster_name based on the unique role name.

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
Java cookbook because all the software installed runs on Java.
Tomcat cookbook.
Fog Gem for SimpleDB manipulation.

## Platform

* Ubuntu 12.04+ [tested heavily.]
* Probably other Linux Distros with some tweaking. This cookbook does not call any package managers directly but rather through the chef package resource, but package names and installation details may differ.

Attributes
==========

See the contents of attributes/default.rb where there are accurate comments and self-explanatory attribute names.

Recipes
=======

default.rb
install.rb
awscredentials.rb
cassandra.rb
optimizations.rb
priam.rb
simpledbconfig.rb

Usage
=====

Include cassandra-priam in your unique role's runlist.

## Minimum recommended deployment variables:

# singleregion:

"cassandra": {
  "priam_s3_bucket": "YOURORG-cassandra-backups"
}

# multiregion:

"cassandra": {
  "priam_s3_bucket": "YOURORG-cassandra-backups",
  "multiregion": "true",
  "priam_zones_available": "us-east-1a,us-east-1c,us-west-1a,us-west-1b,us-west-1c"
}

## Other recommended settings:

# AWS Keys

"cassandra": {
  "aws": {
      "access_key_id": "YOURKEYID"
      "secret_access_key": "YOURACCESSKEY"
    }
  }
}

# Java

"java": {
  "install_flavor": "oracle",
  "jdk_version": "7",
  "oracle" : {
    "accept_oracle_download_terms": "true"
  }
}

## Putting It Together with Autoscaling Commands

# singleregion

as-create-launch-config unique_cassandra_cluster_name-useast1 --region us-east-1 --image-id ami-a73264ce --instance-type m1.small --monitoring-disabled --group unique_cassandra_cluster_name --key aws_ssh_keypair_id --user-data-file chefregistrationetc.txt
as-create-auto-scaling-group unique_cassandra_cluster_name-useast1 --region us-east-1 --launch-configuration unique_cassandra_cluster_name-useast1 --max-size 4 --min-size 2 --availability-zones us-east-1a,us-east-1c

# multiregion

as-create-launch-config unique_cassandra_cluster_name-useast1 --region us-east-1 --image-id ami-a73264ce --instance-type m1.small --monitoring-disabled --group unique_cassandra_cluster_name --key aws_ssh_keypair_id --user-data-file chefregistrationetc.txt 
as-create-launch-config unique_cassandra_cluster_name-uswest1 --region us-west-1 --image-id ami-acf9cde9 --instance-type m1.small --monitoring-disabled --group unique_cassandra_cluster_name --key aws_ssh_keypair_id --user-data-file chefregistrationetc.txt
as-create-auto-scaling-group unique_cassandra_cluster_name-useast1 --region us-east-1 --launch-configuration unique_cassandra_cluster_name-useast1 --max-size 24 --min-size 12 --availability-zones us-east-1a,us-east-1c
as-create-auto-scaling-group unique_cassandra_cluster_name-uswest1 --region us-west-1 --launch-configuration unique_cassandra_cluster_name-uswest1 --max-size 24 --min-size 12 --availability-zones us-west-1a,us-west-1b,us-west-1c

Development
===========

See the [Github page][5]

[5]: https://github.com/mdsol/cassandra_priam_cookbook

License and Authors
===================

* Author: Alex Trull <atrull@mdsol.com>
* Author: Benton Roberts <broberts@mdsol.com>

Copyright: 2013–2013 Medidata Solutions, Inc.
