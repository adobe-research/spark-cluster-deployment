class spark::master (
    $spark_service_status = 'running',
    $master_port = $::spark::defaults::master_port,
    $web_port    = $::spark::defaults::web_port,
    $install_dir = $::spark::defaults::install_dir,
    $worker_mem,
) inherits spark::defaults {

    class {'spark':
        master      => $::fqdn,
        install_dir => $install_dir,
        worker_mem  => $worker_mem,
    }
    Class['spark'] -> Class['spark::master']

    # The Upstart service file.
    file {'/etc/init/spark-master.conf':
        content => template('spark/spark-master.conf.erb'),
        mode    => '0644',
        owner   => 'root',
        group   => 'root',
        notify  => Service['spark-master'], 
    } 

    file { "${install_dir}/bin/spark-master-runner.sh":
        content => template('spark/spark-master-runner.sh.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0744',
    }

    # The service that runs the master server. 
    service {'spark-master': 
        ensure   => $spark_service_status, 
        require  => [File['/etc/init/spark-master.conf'], File["${install_dir}/bin/spark-master-runner.sh"]], 
        hasrestart => true,
        hasstatus => true,
        restart => '/sbin/initctl restart spark-master',
        start => '/sbin/initctl start spark-master',
        stop => '/sbin/initctl stop spark-master',
        status => '/sbin/initctl status spark-master | grep "/running" 1>/dev/null 2>&1',
    }
}
