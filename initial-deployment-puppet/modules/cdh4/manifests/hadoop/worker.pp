# == Class cdh4::hadoop::worker
# Wrapper class for Hadoop Worker node services:
# - DataNode
# - NodeManager (YARN)
# OR
# - TaskTracker (MRv1)
#
# This class will attempt to create and manage the required
# local worker directories defined in the $datanode_mounts array.
# You must make sure that the paths defined in $datanode_mounts are
# formatted and mounted properly yourself; The CDH4 module does not
# manage them.
#
class cdh4::hadoop::worker {
    Class['cdh4::hadoop'] -> Class['cdh4::hadoop::worker']

    cdh4::hadoop::worker::paths { $::cdh4::hadoop::datanode_mounts: }

    class { 'cdh4::hadoop::datanode':
        require => Cdh4::Hadoop::Worker::Paths[$::cdh4::hadoop::datanode_mounts],
    }

    # YARN uses NodeManager.
    if $::cdh4::hadoop::use_yarn {
        class { 'cdh4::hadoop::nodemanager':
            require => Cdh4::Hadoop::Worker::Paths[$::cdh4::hadoop::datanode_mounts],
        }
    }
    # MRv1 uses TaskTracker.
    else {
        class { 'cdh4::hadoop::tasktracker':
            require => Cdh4::Hadoop::Worker::Paths[$::cdh4::hadoop::datanode_mounts],
        }
    }
}
