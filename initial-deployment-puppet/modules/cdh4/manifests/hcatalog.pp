# == Class cdh4::hcatalog
# This class doesn't yet do anything other than
# install the hcatalog package.  This will be expanded
# If/when we need more functionality (hcatalog-server, etc.),
#
class cdh4::hcatalog {
    package { 'hcatalog':
        ensure => 'installed',
    }
}
