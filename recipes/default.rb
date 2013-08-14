# setup java
# this should be replaced with the java cookbook
include_recipe "priam-cassandra::oraclejava6"

# install cassandra database server
include_recipe "priam-cassandra::cassandra"

# install priam cluster management
include_recipe "priam-cassandra::priam"

# install opscenter cluster monitoring
include_recipe "priam-cassandra::opscenter"

# setup agents for the above (priam and opscenter)
include_recipe "priam-cassandra::agents"

# setup Priam/Cassandra configuration in Amazon SDB
include_recipe "priam-cassandra::simpledbconfig"

# setup up performance optimizations
include_recipe "priam-cassandra::optimizations"

# startup
#include_recipe "priam-cassandra::startup"
