#

class { '::cdh4::hadoop':
    namenode_hosts    => ['localhost', 'nonya'],
    dfs_name_dir      => '/var/lib/hadoop/name',
    nameservice_id    => 'test-cdh4',
    journalnode_hosts => ['localhost', 'nonya'],
}

include cdh4::hadoop::namenode::primary
