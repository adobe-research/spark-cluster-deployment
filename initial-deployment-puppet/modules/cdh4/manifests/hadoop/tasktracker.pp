# == Class cdh4::hadoop::tasktracker
# Installs and configures Hadoop MRv1 TaskTracker.
class cdh4::hadoop::tasktracker {
    Class['cdh4::hadoop'] -> Class['cdh4::hadoop::tasktracker']

    if $::cdh4::hadoop::use_yarn {
        fail('Cannot use Hadoop MRv1 JobTrackker if cdh4::hadoop::use_yarn is true.')
    }

    # install tasktracker daemon package
    package { 'hadoop-0.20-mapreduce-tasktracker':
        ensure => 'installed'
    }

    service { 'hadoop-0.20-mapreduce-tasktracker':
        ensure     => 'running',
        enable     => true,
        hasstatus  => true,
        hasrestart => true,
        alias      => 'tasktracker',
        require    => Package['hadoop-0.20-mapreduce-tasktracker'],
    }
}