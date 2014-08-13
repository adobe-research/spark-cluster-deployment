# == Class cdh4::hue::defaults
#
class cdh4::hue::defaults {
    $http_host                = '0.0.0.0'
    $http_port                = 8888
    $secret_key               = undef

    # Set Hue Oozie defaults to those already
    # set in the cdh4::oozie class.
    if (defined(Class['cdh4::oozie'])) {
        $oozie_url                = $cdh4::oozie::url
        # Is this the proper default values?  I'm not sure.
        $oozie_security_enabled   = $cdh4::hue::defaults::oozie_security_enabled
    }
    # Otherwise disable Oozie interface for Hue.
    else {
        $oozie_url                = undef
        $oozie_security_enabled   = undef
    }

    $smtp_host                = 'localhost'
    $smtp_port                = 25
    $smtp_user                = undef
    $smtp_password            = undef
    $smtp_from_email          = undef

    $ssl_private_key          = '/etc/ssl/private/hue.key'
    $ssl_certificate          = '/etc/ssl/certs/hue.cert'

    # if httpfs is enabled, the default httpfs port
    # will be used, instead of the webhdfs port.
    $httpfs_enabled           = false

    $ldap_url                 = undef
    $ldap_cert                = undef
    $ldap_nt_domain           = undef
    $ldap_bind_dn             = undef
    $ldap_base_dn             = undef
    $ldap_bind_password       = undef
    $ldap_username_pattern    = undef
    $ldap_user_filter         = undef
    $ldap_user_name_attr      = undef
    $ldap_group_filter        = undef
    $ldap_group_name_attr     = undef
    $ldap_group_member_attr   = undef

    $hue_ini_template         = 'cdh4/hue/hue.ini.erb'

}