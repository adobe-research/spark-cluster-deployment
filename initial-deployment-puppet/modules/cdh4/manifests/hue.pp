# == Class cdh4::hue
#
# Installs hue, sets up the hue.ini file
# and ensures that hue server is running.
# This requires that cdh4::hadoop is included.
#
# If cdh4::hive and/or cdh4::oozie are included
# on this node, hue will be configured to interface
# with hive and oozie.
#
# == Parameters
# $http_host              - IP for webservice to bind.
# $http_port              - Port for webservice to bind.
# $secret_key             - Secret key used for session hashing.
#
# $oozie_url              - URL for Oozie API.  If cdh4::oozie is included,
#                           this will be inferred.  Else this will be disabled.
# $oozie_security_enabled - Default: false.
#
# $smtp_host              - SMTP host for email notifications.
#                           Default: undef, SMTP will not be configured.
# $smtp_port              - SMTP port.                             Default: 25
# $smtp_from_email        - Sender email address of notifications. Default: undef
# $smtp_username          - Username for SMTP authentication.      Default: undef
# $smtp_password          - Password for SMTP authentication.      Default: undef
#
# $httpfs_enabled         - If true, Hue will be configured to interact with HDFS via
#                           HttpFS rather than the default WebHDFS.  You must
#                           manually configure HttpFS on your namenode.
#
# $ssl_private_key        - Path to SSL private key.  Default: /etc/hue/hue.key
# $ssl_certificate        - Path to SSL certificate.  Default: /etc/hue/hue.cert
#                           If ssl_private_key and ssl_certificate are set to the defaults,
#                           a self-signed certificate will be generated automatically for you.
#
# === LDAP parameters:
# See hue.ini comments for documentation.  By default these are undefined.
#
# $ldap_url
# $ldap_cert
# $ldap_nt_domain
# $ldap_bind_dn
# $ldap_base_dn
# $ldap_bind_password
# $ldap_username_pattern
# $ldap_user_filter
# $ldap_user_name_attr
# $ldap_group_filter
# $ldap_group_name_attr
# $ldap_group_member_attr
#
class cdh4::hue(
    $http_host                = $cdh4::hue::defaults::http_host,
    $http_port                = $cdh4::hue::defaults::http_port,
    $secret_key               = $cdh4::hue::defaults::secret_key,

    $oozie_url                = $cdh4::hue::defaults::oozie_url,
    $oozie_security_enabled   = $cdh4::hue::defaults::oozie_security_enabled,

    $smtp_host                = $cdh4::hue::defaults::smtp_host,
    $smtp_port                = $cdh4::hue::defaults::smtp_port,
    $smtp_user                = $cdh4::hue::defaults::smtp_user,
    $smtp_password            = $cdh4::hue::defaults::smtp_password,
    $smtp_from_email          = $cdh4::hue::defaults::smtp_from_email,

    $httpfs_enabled           = $cdh4::hue::defaults::httpfs_enabled,

    $ssl_private_key          = $cdh4::hue::defaults::ssl_private_key,
    $ssl_certificate          = $cdh4::hue::defaults::ssl_certificate,

    $ldap_url                 = $cdh4::hue::defaults::ldap_url,
    $ldap_cert                = $cdh4::hue::defaults::ldap_cert,
    $ldap_nt_domain           = $cdh4::hue::defaults::ldap_nt_domain,
    $ldap_bind_dn             = $cdh4::hue::defaults::ldap_bind_dn,
    $ldap_base_dn             = $cdh4::hue::defaults::ldap_base_dn,
    $ldap_bind_password       = $cdh4::hue::defaults::ldap_bind_password,
    $ldap_username_pattern    = $cdh4::hue::defaults::ldap_username_pattern,
    $ldap_user_filter         = $cdh4::hue::defaults::ldap_user_filter,
    $ldap_user_name_attr      = $cdh4::hue::defaults::ldap_user_name_attr,
    $ldap_group_filter        = $cdh4::hue::defaults::ldap_group_filter,
    $ldap_group_name_attr     = $cdh4::hue::defaults::ldap_group_name_attr,
    $ldap_group_member_attr   = $cdh4::hue::defaults::ldap_group_member_attr,

    $hue_ini_template       = $cdh4::hue::defaults::hue_ini_template
) inherits cdh4::hue::defaults
{
    Class['cdh4::hadoop'] -> Class['cdh4::hue']

    package { ['hue', 'hue-server']:
        ensure => 'installed'
    }

    # Managing the hue user here so we can add
    # it to the hive group if hive-site.xml is
    # not world readable.
    user { 'hue':
        gid        => 'hue',
        comment    => 'Hue daemon',
        home       => '/usr/share/hue',
        shell      => '/bin/false',
        managehome => false,
        system     => true,
        require    => [Package['hue'], Package['hue-server']],
    }
    # hive-site.xml might not be world readable.
    if (defined(Class['cdh4::hive'])) {
        # Below, if hive is enabled, the hue
        # user will be added to the hive group.
        # It isn't added here because Puppet only
        # allows group addtions to a User once,
        # and we might also have to add the ssl-cert group.
        $hive_enabled = true

        # make sure cdh4::hive is applied before cdh4::hue.
        Class['cdh4::hive']  -> Class['cdh4::hue']

        # Growl.  The packaged hue init.d script
        # has a bug where it doesn't --chuid to hue.
        # this causes hue not to be able to read the
        # hive-site.xml file here, even though it is
        # in the hive group.  Install our own patched
        # init.d instead.  This will be removed once
        # Cloudera fixes the problem.
        # See: https://issues.cloudera.org/browse/HUE-1398
        file { '/etc/init.d/hue':
            source  => 'puppet:///modules/cdh4/hue/hue.init.d.sh',
            mode    => '0755',
            owner   => 'root',
            group   => 'root',
            require => Package['hue'],
            notify  => Service['hue'],
        }
    }

    # If SSL file paths are given, configure Hue to use SSL.
    if ($ssl_private_key and $ssl_certificate) {
        # Below, if ssl is enabled, the hue
        # user will be added to the ssl-cert group.
        # It isn't added here because Puppet only
        # allows group addtions to a User once,
        # and we might also have to add the hive group.
        # Adding the ssl-cert group allows hue to read
        # files in /etc/ssl/private.
        $ssl_enabled = true
        if (!defined(Package['openssl'])) {
            package { 'openssl':
                ensure => 'installed',
                before => User['hue'],
            }
        }
        if (!defined(Package['ssl-cert'])) {
            package { 'ssl-cert':
                ensure => 'installed',
                before => User['hue'],
            }
        }
        if (!defined(Package['python-openssl'])) {
            package { 'python-openssl':
                ensure => 'installed',
            }
        }

        # If the SSL settings are left at the defaults,
        # then generate a default self-signed certificate.
        if (($ssl_private_key == $cdh4::hue::defaults::ssl_private_key) and
            ($ssl_certificate == $cdh4::hue::defaults::ssl_certificate)) {

            exec { 'generate_hue_ssl_private_key':
                command => "/usr/bin/openssl genrsa 2048 > ${ssl_private_key}",
                creates => $ssl_private_key,
                require => [Package['openssl'], User['hue']],
                notify  => Service['hue'],
                before  => File[$ssl_private_key],
            }
            exec { 'generate_hue_ssl_certificate':
                command => "/usr/bin/openssl req -new -x509 -nodes -sha1 -subj '/C=US/ST=Denial/L=Nonya/O=Dis/CN=www.example.com' -key ${ssl_private_key} -out ${ssl_certificate}",
                creates => $ssl_certificate,
                require => Exec['generate_hue_ssl_private_key'],
                notify  => Service['hue'],
                before  => File[$ssl_certificate],
            }
        }

        # Ensure SSL files have proper permissions.
        file { $ssl_private_key:
            mode    => '0440',
            owner   => 'root',
            group   => 'hue',
            before  => Service['hue'],
        }
        file { $ssl_certificate:
            mode    => '0444',
            owner   => 'root',
            group   => 'hue',
            before  => Service['hue'],
        }
    }

    # Stupid Puppet hack:  Need to select all
    # of the groups we are going to add the
    # hue user to before we actually do it.

    # add hue to the proper groups based on hive
    # and ssl usage.
    if ($hive_enabled and $ssl_enabled) {
        $hue_groups = ['hive', 'ssl-cert']
    }
    elsif ($hive_enabled) {
        $hue_groups = ['hive']
    }
    elsif($ssl_enabled) {
        $hue_groups = ['ssl-cert']
    }

    if ($hue_groups) {
        # Add the hue user to the hive group.
        User['hue'] { groups +> $hue_groups }
    }

    if (defined(Package['sqoop'])) {
        $sqoop = 'sqoop'
    }
    elsif (defined(Package['sqoop2'])) {
        $sqoop = 'sqoop2'
    }
    else {
        $sqoop = false
    }

    $namenode_host = $::cdh4::hadoop::primary_namenode_host
    file { '/etc/hue/hue.ini':
        content => template($hue_ini_template),
        require => Package['hue-server'],
    }

    service { 'hue':
        ensure     => 'running',
        enable     => true,
        hasrestart => true,
        hasstatus  => true,
        subscribe  => File['/etc/hue/hue.ini'],
        require    => [Package['hue-server'], User['hue']],
    }
}
