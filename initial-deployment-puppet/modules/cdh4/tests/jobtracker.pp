
class { '::cdh4::hadoop':
    use_yarn       => false,
    namenode_hosts => ['localhost'],
    dfs_name_dir   => '/var/lib/hadoop/name',
}

# jobtracker requires namenode
include cdh4::hadoop::master
include cdh4::hadoop::jobtracker
