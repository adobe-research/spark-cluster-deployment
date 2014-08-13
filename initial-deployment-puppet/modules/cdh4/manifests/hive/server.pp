# == Class cdh4::hive::server
# Configures hive-server2.  Requires that cdh4::hadoop is included so that
# hadoop-client is available to create hive HDFS directories.
#
# See: http://www.cloudera.com/content/cloudera-content/cloudera-docs/CDH4/4.2.0/CDH4-Installation-Guide/cdh4ig_topic_18_5.html
#
class cdh4::hive::server
{
    # cdh4::hive::server requires hadoop client and configs are installed.
    Class['cdh4::hadoop'] -> Class['cdh4::hive::server']
    Class['cdh4::hive']   -> Class['cdh4::hive::server']

    package { 'hive-server2':
        ensure => 'installed',
        alias  => 'hive-server',
    }

    # sudo -u hdfs hadoop fs -mkdir /user/hive
    # sudo -u hdfs hadoop fs -chmod 0775 /user/hive
    # sudo -u hdfs hadoop fs -chown hive:hadoop /user/hive
    cdh4::hadoop::directory { '/user/hive':
        owner   => 'hive',
        group   => 'hadoop',
        mode    => '0775',
        require => Package['hive'],
    }
    # sudo -u hdfs hadoop fs -mkdir /user/hive/warehouse
    # sudo -u hdfs hadoop fs -chmod 1777 /user/hive/warehouse
    # sudo -u hdfs hadoop fs -chown hive:hadoop /user/hive/warehouse
    cdh4::hadoop::directory { '/user/hive/warehouse':
        owner   => 'hive',
        group   => 'hadoop',
        mode    => '1777',
        require => Cdh4::Hadoop::Directory['/user/hive'],
    }

    service { 'hive-server2':
        ensure     => 'running',
        require    => Package['hive-server2'],
        hasrestart => true,
        hasstatus  => true,
    }
}