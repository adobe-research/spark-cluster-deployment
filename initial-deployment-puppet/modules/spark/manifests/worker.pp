class spark::worker (
    $master,
    $spark_service_status = 'running',
    $master_port = $::spark::defaults::master_port,
    $web_port    = $::spark::defaults::web_port,
    $install_dir = $::spark::defaults::install_dir,
    $cores       = $::spark::defaults::cores,
    $memory      = $::spark::defaults::memory,
    $scratch_dir = $::spark::defaults::scratch_dir,
) inherits spark::defaults {

    class {'spark':
        master      => $master,
        install_dir => $install_dir,
        worker_mem  => $memory,

    }
    Class['spark'] -> Class['spark::worker']

    # The Upstart service file.
    file {'/etc/init/spark-worker.conf':
        content => template('spark/spark-worker.conf.erb'),
        mode    => '0644',
        owner   => 'root',
        group   => 'root',
        notify  => Service['spark-worker'], 
    } 

    file { "${install_dir}/bin/spark-worker-runner.sh":
        content => template('spark/spark-worker-runner.sh.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0744',
    }

    # The service that runs the master server. 
    service {'spark-worker': 
        ensure   => $spark_service_status, 
        #provider => 'upstart',
        require  => [File['/etc/init/spark-worker.conf'], File["${install_dir}/bin/spark-worker-runner.sh"]],
        hasrestart => true,
        hasstatus => true,
        restart => '/sbin/initctl restart spark-worker',
        start => '/sbin/initctl start spark-worker',
        stop => '/sbin/initctl stop spark-worker',
        status => '/sbin/initctl status spark-worker | grep "/running" 1>/dev/null 2>&1'
    }
}
