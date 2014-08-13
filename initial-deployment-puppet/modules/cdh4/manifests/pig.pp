# == Class cdh4::pig
#
# Installs and configures Apache Pig.
#
class cdh4::pig {
    package { 'pig':
        ensure => 'installed',
    }

    file { '/etc/pig/conf/pig.properties':
        content => template('cdh4/pig/pig.properties.erb'),
        require => Package['pig'],
    }
}
