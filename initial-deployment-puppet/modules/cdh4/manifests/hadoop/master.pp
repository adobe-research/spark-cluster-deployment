# == Class cdh4::hadoop::master
# Wrapper class for Hadoop master node services:
# - NameNode
# - ResourceManager and HistoryServer (YARN)
# OR
# - JobTracker (MRv1).
#
class cdh4::hadoop::master {
    Class['cdh4::hadoop'] -> Class['cdh4::hadoop::master']

    include cdh4::hadoop::namenode::primary

    # YARN uses ResourceManager and HistoryServer,
    # NOT JobTracker.
    if $::cdh4::hadoop::use_yarn {
        include cdh4::hadoop::resourcemanager
        include cdh4::hadoop::historyserver
    }
    # MRv1 just uses JobTracker
    else {
        include cdh4::hadoop::jobtracker
    }
}