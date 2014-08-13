#

class { '::cdh4::hadoop':
    namenode_hosts => ['localhost'],
    dfs_name_dir   => '/var/lib/hadoop/name',
}

# historyserver requires namenode
include cdh4::hadoop::master
include cdh4::hadoop::historyserver
