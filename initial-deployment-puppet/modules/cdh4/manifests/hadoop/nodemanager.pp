# == Class cdh4::hadoop::nodemanager
# Installs and configures a Hadoop NodeManager worker node.
#
class cdh4::hadoop::nodemanager {
    Class['cdh4::hadoop'] -> Class['cdh4::hadoop::nodemanager']

    if !$::cdh4::hadoop::use_yarn {
        fail('Cannot use Hadoop YARN NodeManager if cdh4::hadoop::use_yarn is false.')
    }

    package { ['hadoop-yarn-nodemanager', 'hadoop-mapreduce']:
        ensure => 'installed',
    }

    # NodeManager (YARN TaskTracker)
    service { 'hadoop-yarn-nodemanager':
        ensure     => 'running',
        enable     => true,
        hasstatus  => true,
        hasrestart => true,
        alias      => 'nodemanager',
        require    => [Package['hadoop-yarn-nodemanager', 'hadoop-mapreduce']],
    }
}

