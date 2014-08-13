# == Class cdh4::hive::master
# Wrapper class for hive::server, hive::metastore, and hive::metastore::* databases.
#
# Include this class on your Hive master node with $metastore_database
# set to one of the available metastore backend classes in the hive/metastore/
# directory.  If you want to set up a hive metastore database backend that
# is not supported here, you may set $metastore_databse to undef.
#
# You must separately ensure that your $metastore_database (e.g. mysql) package
# is installed.
#
# == Parameters
# $metastore_database - Name of metastore database to use.  This should be
#                       the name of a cdh4::hive::metastore::* class in
#                       hive/metastore/*.pp.
#
class cdh4::hive::master($metastore_database = 'mysql') {
    class { 'cdh4::hive::server':    }
    class { 'cdh4::hive::metastore': }

    # Set up the metastore database by including
    # the $metastore_database_class.
    $metastore_database_class = "cdh4::hive::metastore::${metastore_database}"
    if ($metastore_database) {
        class { $metastore_database_class: }
    }

    # Make sure the $metastore_database_class is included and set up
    # before we start the hive-metastore service
    Class[$metastore_database_class] -> Class['cdh4::hive::metastore']
}