# == Class cdh4::hive::metastore::mysql
# Configures and sets up a MySQL metastore for Hive.
#
# Note that this class does not support running
# the Metastore database on a different host than where your
# hive-metastore service will run.  Permissions will only be granted
# for localhost MySQL users, so hive-metastore must run on this node.
#
# Also, root must be able to run /usr/bin/mysql with no password and have permissions
# to create databases and users and grant permissions.
#
# See: http://www.cloudera.com/content/cloudera-content/cloudera-docs/CDH4/latest/CDH4-Installation-Guide/cdh4ig_hive_metastore_configure.html
#
# == Parameters
# $schema_version - When installing the metastore database, this version of
#                   the schema will be created.  This must match an .sql file
#                   schema version found in /usr/lib/hive/scripts/metastore/upgrade/mysql.
#                   Default: 0.10.0
#
class cdh4::hive::metastore::mysql($schema_version = '0.10.0') {
    Class['cdh4::hive'] -> Class['cdh4::hive::metastore::mysql']

    if (!defined(Package['libmysql-java'])) {
        package { 'libmysql-java':
            ensure => 'installed',
        }
    }
    # symlink the mysql.jar into /var/lib/hive/lib
    file { '/usr/lib/hive/lib/libmysql-java.jar':
        ensure  => 'link',
        target  => '/usr/share/java/mysql.jar',
        require => Package['libmysql-java'],
    }

    $db_name = $cdh4::hive::jdbc_database
    $db_user = $cdh4::hive::jdbc_username
    $db_pass = $cdh4::hive::jdbc_password

    # Only use -u or -p flag to mysql commands if
    # root username or root password are set.
    $username_option = $cdh4::hive::db_root_username ? {
        undef   => '',
        default => "-u'${cdh4::hive::db_root_username}'",
    }
    $password_option = $cdh4::hive::db_root_password ? {
        undef   => '',
        default => "-p'${cdh4::hive::db_root_password}'",
    }

    # hive is going to need an hive database and user.
    exec { 'hive_mysql_create_database':
        command => "/usr/bin/mysql ${username_option} ${password_option} -e \"
CREATE DATABASE ${db_name}; USE ${db_name};
SOURCE /usr/lib/hive/scripts/metastore/upgrade/mysql/hive-schema-${schema_version}.mysql.sql;\"",
        unless  => "/usr/bin/mysql ${username_option} ${password_option} -e 'SHOW DATABASES' | /bin/grep -q ${db_name}",
        user    => 'root',
    }
    exec { 'hive_mysql_create_user':
        command => "/usr/bin/mysql ${username_option} ${password_option}  -e \"
CREATE USER '${db_user}'@'localhost' IDENTIFIED BY '${db_pass}';
CREATE USER '${db_user}'@'127.0.0.1' IDENTIFIED BY '${db_pass}';
GRANT ALL PRIVILEGES ON ${db_name}.* TO '${db_user}'@'localhost' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON ${db_name}.* TO '${db_user}'@'127.0.0.1' WITH GRANT OPTION;
FLUSH PRIVILEGES;\"",
        unless  => "/usr/bin/mysql ${username_option} ${password_option} -e \"SHOW GRANTS FOR '${db_user}'@'127.0.0.1'\" | grep -q \"TO '${db_user}'\"",
        user    => 'root',
    }
}