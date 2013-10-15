Description
===========

This cookbook exists to achieve a deployment of a [Priam][1] Managed [Cassandra][2] Cluster.

This cookbook elects a leader to create the necessary [SimpleDB][3] databases/configuration entries to manage the deployment along with some Priam/Cassandra configuration [Properties][4] managed via chef attributes.

Priam is a sidecar application that takes care of Cassandra Configuration, Startup, Seeding and Node Replacement, Backups (to s3) and Restoration (from s3). It makes the lifecycle of Cassandra clusters much easier to manage.

This cookbook installs the [JNA][5] package.

### Special Caveats:

This cookbook and the software it deploys are only designed to work under AWS EC2 with [Autoscaling][6] and [SimpleDB][3].

You should check that the credentials you provide have the necessary accesss to use the relevant AWS services.

### General Caveats:

#### Java:

The software this cookbook installs has mostly been tested with the Oracle JRE - your mileage may vary on other JRE builds. 

#### SimpleDB:

Contact Amazon to get your SimpleDB limits increased moderately with your usage.

#### Cluster, Role and Autoscaling Group Naming

When creating a cluster, there are several places where the reference must be identical/matching for things to work as expected.

These references should ideally all be the same and globally unique - although some are suffixed with identifiers, and some are not that global (security groups are regional).

Dashes are a used as a separator, so we try and use underscores where possible.

Use the following as a guide / concept for your own naming:

Autoscaling Group Name : ````unique_cassandra_cluster_one-useast1````

Note that we indicate the region the group is in at the end of the name with a dash separator. 

Role Name :              ````unique-cassandra-cluster-one | unique_cassandra_cluster_one````

This must be unique within the chef API, shared between all members members of the cluster.

Cluster Name :           ````unique_cassandra_cluster_one````

If a cluster name is not configured directly we will make one out of the role name, replacing dashes (-) with underscores (_)

Security Group Name :    ````unique_cassandra_cluster_one````

Priam will attempt to configure security groups itself in each region if it is in multiregion mode. It will not however create them : They should be created matching the cluster name (i.e. the ASG name before the region suffix).

See the ec2/autoscaling commands at the bottom of this document for a clearer picture of some of the implications.

#### AWS Credentials:

This cookbook tries to pick up AWS credentials from an encrypted databag by default in the same location as the ebs cookbook and others use (bag: credentials item: aws). See the attributes for more information.

Requirements
============
* Chef 10.16.4+
* [Amazon Autoscaling][6]
* [Amazon SimpleDB][3]
* [Java cookbook][8]
* [Tomcat cookbook][9]
* [Fog Gem][10]

## Platform

* Ubuntu 12.04+ [tested heavily]
* Probably other Linux Distros with some tweaking of package names where appropriate. 

Note: This cookbook does not call any package managers directly but rather through the chef package resource, but package names and installation paths may differ.

Attributes
==========

See the contents of `attributes/default.rb` where there are accurate comments and self-explanatory attribute names.

Recipes
=======

* `default.rb` : A dummy recipe pointing to install.rb
* `install.rb` : Installs everything by calling the rest of the recipes in the right order. Includes a leadership election section for applying simpledbconfig
* `awscredentials.rb` : Creates AWS Credentials on the /etc filesystem
* `cassandra.rb` : Installs Cassandra
* `optimizations.rb` : Applies Optimizations to limits.d
* `priam.rb` : Installs Priam
* `simpledbconfig.rb` : Applies SimpleDB configuration

Usage
=====

Include cassandra-priam in your unique role's runlist.

### Recommended deployment variables:

The following example variables should be in the unique role's "overrides" attributes section:

#### singleregion:

```JSON
{
  "cassandra": {
    "priam_s3_bucket": "YOURORG-cassandra-backups",
  },
  "tomcat":{
     "base_version": "7"
  },
  "java": {
    "install_flavor": "oracle",
    "jdk_version": "7",
    "oracle": {
      "accept_oracle_download_terms": "true"
    }
  }
}
```

#### multiregion:

```JSON
{
  "cassandra": {
    "priam_s3_bucket": "YOURORG-cassandra-backups",
    "priam_multiregion_enable": "true",
    "priam_endpoint_snitch": "org.apache.cassandra.locator.Ec2MultiRegionSnitch",
    "priam_zones_available": "us-east-1a,us-east-1b,us-east-1c,us-west-1a,us-west-1b,us-west-1c",
  },
  "tomcat":{
     "base_version": "7"
  },
  "java": {
      "install_flavor": "oracle",
      "jdk_version": "7",
      "oracle" : {
        "accept_oracle_download_terms": "true"
      }
   }
}
```

### Putting It Together with Autoscaling Commands

#### singleregion

```SHELL
as-create-launch-config unique_cassandra_cluster_one-useast1 --region us-east-1 --image-id ami-a73264ce --instance-type m1.small --monitoring-disabled --group unique-cassandra-cluster-name --key aws_ssh_keypair_id --user-data-file chefregistrationetc.txt
as-create-auto-scaling-group unique_cassandra_cluster_one-useast1 --region us-east-1 --launch-configuration unique_cassandra_cluster_name-useast1 --max-size 4 --min-size 2 --availability-zones us-east-1a,us-east-1b,us-east-1c
```

#### multiregion

```SHELL
ec2-create-group --region us-east-1 unique_cassandra_cluster_two -d unique_cassandra_cluster_two
ec2-create-group --region us-west-1 unique_cassandra_cluster_two -d unique_cassandra_cluster_two
as-create-launch-config unique_cassandra_cluster_two-useast1 --region us-east-1 --image-id ami-a73264ce --instance-type m1.small --monitoring-disabled --group unique_cassandra_cluster_two --key aws_ssh_keypair_id --user-data-file chefregistrationetc.txt 
as-create-launch-config unique_cassandra_cluster_two-uswest1 --region us-west-1 --image-id ami-acf9cde9 --instance-type m1.small --monitoring-disabled --group unique_cassandra_cluster_two --key aws_ssh_keypair_id --user-data-file chefregistrationetc.txt
as-create-auto-scaling-group unique_cassandra_cluster_two-useast1 --region us-east-1 --launch-configuration unique_cassandra_cluster_two-useast1 --max-size 4 --min-size 2 --availability-zones us-east-1a,us-east-1b,us-east-1c
as-create-auto-scaling-group unique_cassandra_cluster_two-uswest1 --region us-west-1 --launch-configuration unique_cassandra_cluster_two-uswest1 --max-size 4 --min-size 2 --availability-zones us-west-1a,us-west-1b,us-west-1c
```

Development
===========

See the [Github page][7]

[1]: https://github.com/Netflix/Priam
[2]: http://planetcassandra.org
[3]: http://aws.amazon.com/simpledb
[4]: https://github.com/Netflix/Priam/wiki/Properties
[5]: https://github.com/twall/jna
[6]: http://aws.amazon.com/autoscaling
[7]: https://github.com/mdsol/cassandra_priam_cookbook
[8]: http://community.opscode.com/cookbooks/java
[9]: http://community.opscode.com/cookbooks/tomcat
[10]: https://rubygems.org/gems/fog

Authors
=======

* Author: Alex Trull <atrull@mdsol.com>
* Author: Benton Roberts <broberts@mdsol.com>

Copyright: 2013–2013 Medidata Solutions, Inc.
