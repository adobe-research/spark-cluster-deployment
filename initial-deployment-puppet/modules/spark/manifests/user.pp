class spark::user {
 
    group {'spark':
        ensure => present,
    }

    user {'spark':
        ensure  => present,
        shell   => '/bin/bash',
        gid     => 'spark',
        require => Group['spark'],
    }

}
