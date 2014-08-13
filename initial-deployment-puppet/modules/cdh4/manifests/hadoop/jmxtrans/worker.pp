# == Class cdh4::hadoop::jmxtrans::worker
# Convenience class to include jmxtrans classes for DataNode and NodeManager
class cdh4::hadoop::jmxtrans::worker(
    $ganglia        = undef,
    $graphite       = undef,
    $outfile        = undef,
)
{
    class { ['cdh4::hadoop::jmxtrans::datanode', 'cdh4::hadoop::jmxtrans::nodemanager']:
        ganglia  => $ganglia,
        graphite => $graphite,
        outfile  => $outfile,
    }
}