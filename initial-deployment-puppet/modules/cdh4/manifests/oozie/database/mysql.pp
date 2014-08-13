# == Class cdh4::oozie::database::mysql
# Configures and sets up a MySQL database for Oozie.
#
# Note that this class does not support running
# the Oozie database on a different host than where your
# oozie server will run.  Permissions will only be granted
# for localhost MySQL users, so oozie server must run on this node.
#
# Also, root must be able to run /usr/bin/mysql with no password and have permissions
# to create databases and users and grant permissions.
#
# You probably shouldn't be including this class directly.  Instead, include
# cdh4::oozie::server with database => 'mysql'.
#
# See: http://www.cloudera.com/content/cloudera-content/cloudera-docs/CDH4/4.2.1/CDH4-Installation-Guide/cdh4ig_topic_17_6.html
#
class cdh4::oozie::database::mysql {
    if (!defined(Package['libmysql-java'])) {
        package { 'libmysql-java':
            ensure => 'installed',
        }
    }

    # symlink mysql.jar into /var/lib/oozie
    file { '/var/lib/oozie/mysql.jar':
        ensure  => 'link',
        target  => '/usr/share/java/mysql.jar',
        require => Package['libmysql-java'],
    }

    $db_name = $cdh4::oozie::server::jdbc_database
    $db_user = $cdh4::oozie::server::jdbc_username
    $db_pass = $cdh4::oozie::server::jdbc_password

    # oozie is going to need an oozie database and user.
    exec { 'oozie_mysql_create_database':
        command => "/usr/bin/mysql -e \"
CREATE DATABASE ${db_name};
GRANT ALL PRIVILEGES ON ${db_name}.* TO '${db_user}'@'localhost' IDENTIFIED BY '${db_pass}';
GRANT ALL PRIVILEGES ON ${db_name}.* TO '${db_user}'@'127.0.0.1' IDENTIFIED BY '${db_pass}';\"",
        unless  => "/usr/bin/mysql -BNe 'SHOW DATABASES' | /bin/grep -q ${db_name}",
        user    => 'root',
    }

    # run ooziedb.sh to create the oozie database schema
    exec { 'oozie_mysql_create_schema':
        command => '/usr/lib/oozie/bin/ooziedb.sh create -run',
        require => [Exec['oozie_mysql_create_database'], File['/var/lib/oozie/mysql.jar']],
        unless  => "/usr/bin/mysql -u${db_user} -p'${db_pass}' ${db_name} -BNe 'SHOW TABLES;' | /bin/grep -q OOZIE_SYS",
        user    => 'oozie',
    }
}