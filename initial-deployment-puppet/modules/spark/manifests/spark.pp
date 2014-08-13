class spark (
    $master,
    $worker_mem,
    $install_dir
) {
    require spark::user


    # Better would be if they had a package repository available, but they do not at this moment.
    # (Nor do I, so this is the cleanest way without package managers).
    file {$install_dir:
        ensure  => directory,
        source  => 'puppet:///modules/spark/spark',
        mode    => '0744',
        recurse => true,
        owner   => 'root',
        group   => 'root',
        require => User['spark'],
    }

    
    file {"${install_dir}/conf/spark-env.sh":
        content => template('spark/spark-env.sh.erb'),
        mode    => '0744',
        owner   => 'root',
        group   => 'root',
        require => File[$install_dir],
    } 

    #file {"${install_dir}/conf/metrics.properties":
    #    content => template('spark/metrics.properties.erb'),
    #    mode    => '0744',
    #    owner   => 'root',
    #    group   => 'root',
    #    require => File[$install_dir],
    #} 


    # Create log dir for logging.
    file {'/var/log/spark':
        ensure => directory,
        owner   => 'root',
        group   => 'root',
    }
}
