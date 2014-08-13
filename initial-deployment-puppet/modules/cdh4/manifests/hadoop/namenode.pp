# == Class cdh4::hadoop::namenode
# Installs and configureds Hadoop NameNode.
# This will format the NameNode if it is not
# already formatted.  It will also create
# a common HDFS directory hierarchy.
#
# Note:  If you are using HA NameNode (indicated by setting
# cdh4::hadoop::nameservice_id), your JournalNodes should be running before
# this class is applied.
#
class cdh4::hadoop::namenode {
    Class['cdh4::hadoop'] -> Class['cdh4::hadoop::namenode']

    # install namenode daemon package
    package { 'hadoop-hdfs-namenode':
        ensure => installed
    }

    file { "${::cdh4::hadoop::config_directory}/hosts.exclude":
        ensure  => 'present',
        require => Package['hadoop-hdfs-namenode'],
    }

    # Ensure that the namenode directory has the correct permissions.
    file { $::cdh4::hadoop::dfs_name_dir:
        ensure  => 'directory',
        owner   => 'hdfs',
        group   => 'hdfs',
        mode    => '0700',
        require => Package['hadoop-hdfs-namenode'],
    }

    # If $dfs_name_dir/current/VERSION doesn't exist, assume
    # NameNode has not been formated.  Format it before
    # the namenode service is started.
    exec { 'hadoop-namenode-format':
        command => '/usr/bin/hdfs namenode -format',
        creates => "${::cdh4::hadoop::dfs_name_dir_main}/current/VERSION",
        user    => 'hdfs',
        require => File[$::cdh4::hadoop::dfs_name_dir],
    }

    service { 'hadoop-hdfs-namenode':
        ensure     => 'running',
        enable     => true,
        hasstatus  => true,
        hasrestart => true,
        alias      => 'namenode',
        require    => [File["${::cdh4::hadoop::config_directory}/hosts.exclude"], Exec['hadoop-namenode-format']],
    }
}
