# == Define cdh4::hadoop::directory
#
# Creates or removes a directory in HDFS.
#
# == Notes:
# This will not check ownership and permissions
# of a directory.  It will only check for the directories
# existence.  If it does not exist, the directory will be
# created and given specified ownership and permissions.
# This will not attempt to set ownership and permissions
# if the directory already exists.
#
# This define does not support managing files in HDFS,
# only directories.
#
# Ideally this define would be ported into a Puppet File Provider.
# I once spent some time trying to make that work, but it was more
# difficult than it sounds.  For example, you'd need to handle conversion
# between symbolic mode to numeric mode, as I could not find a way to
# get hadoop fs to list numeric modes for comparison.  Perhaps
# there's a way to use HttpFS to do this instead?
#
# == Parameters:
# $path   - HDFS directory path.   Default: $title
# $ensure - present|absent.        Default: present
# $owner  - HDFS directory owner.  Default: hdfs
# $group  - HDFS directory group owner. Default: hdfs
# $mode   - HDFS diretory mode.  Default 0755
#
define cdh4::hadoop::directory (
    $path   = $title,
    $ensure = 'present',
    $owner  = 'hdfs',
    $group  = 'hdfs',
    $mode   = '0755')
{
    Class['cdh4::hadoop'] -> Cdh4::Hadoop::Directory[$title]

    if $ensure == 'present' {
        exec { "cdh4::hadoop::directory ${title}":
            command => "/usr/bin/hadoop fs -mkdir ${path} && /usr/bin/hadoop fs -chmod ${mode} ${path} && /usr/bin/hadoop fs -chown ${owner}:${group} ${path}",
            unless  => "/usr/bin/hadoop fs -test -e ${path}",
            user    => 'hdfs',
        }
    }
    else {
        exec { "cdh4::hadoop::directory ${title}":
            command => "/usr/bin/hadoop fs -rm -R ${path}",
            onlyif  => "/usr/bin/hadoop fs -test -e ${path}",
            user    => 'hdfs',
            require => Service['hadoop-hdfs-namenode'],
        }
    }
}