# == Class cdh4::hive::metastore
#
class cdh4::hive::metastore
{
    Class['cdh4::hive'] -> Class['cdh4::hive::metastore']

    package { 'hive-metastore':
        ensure => 'installed',
    }

    service { 'hive-metastore':
        ensure     => 'running',
        require    => Package['hive-metastore'],
        hasrestart => true,
        hasstatus  => true,
    }
}