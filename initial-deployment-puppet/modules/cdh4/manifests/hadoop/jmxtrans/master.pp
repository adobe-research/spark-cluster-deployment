# == Class cdh4::hadoop::jmxtrans::master
# Convenience class to include jmxtrans classes for NameNode and ResourceManager
class cdh4::hadoop::jmxtrans::master(
    $ganglia        = undef,
    $graphite       = undef,
    $outfile        = undef,
)
{
    class { ['cdh4::hadoop::jmxtrans::namenode', 'cdh4::hadoop::jmxtrans::resourcemanager']:
        ganglia  => $ganglia,
        graphite => $graphite,
        outfile  => $outfile,
    }
}