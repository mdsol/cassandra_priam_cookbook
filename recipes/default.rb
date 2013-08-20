# setup java
# this should be replaced with the java cookbook
include_recipe "priam-cassandra::oraclejava6"

# setup up performance optimizations
include_recipe "priam-cassandra::optimizations"

# install cassandra database server
include_recipe "priam-cassandra::cassandra"

# install priam cluster management
include_recipe "priam-cassandra::priam"

# runit installation and cassandra startup
include_recipe "priam-cassandra::runit"

# install opscenter cluster monitoring
include_recipe "priam-cassandra::opscenter"

