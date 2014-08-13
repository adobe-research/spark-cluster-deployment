# == Class cdh4::hadoop::jmxtrans::nodemanager
# Sets up a jmxtrans instance for a Hadoop NodeManager
# running on the current host.
# Note: This requires the jmxtrans puppet module found at
# https://github.com/wikimedia/puppet-jmxtrans.
#
# == Parameters
# $jmx_port      - NodeManager JMX port.  Default: 9983
# $ganglia       - Ganglia host:port
# $graphite      - Graphite host:port
# $outfile       - outfile to which Kafka stats will be written.
# $objects       - objects parameter to pass to jmxtrans::metrics.  Only use
#                  this if you need to override the default ones that this
#                  class provides.
#
# == Usage
# class { 'cdh4::hadoop::jmxtrans::nodemanager':
#     ganglia => 'ganglia.example.org:8649'
# }
#
class cdh4::hadoop::jmxtrans::nodemanager(
    $jmx_port       = $cdh4::hadoop::defaults::nodemanager_jmxremote_port,
    $ganglia        = undef,
    $graphite       = undef,
    $outfile        = undef,
    $objects        = undef,
) inherits cdh4::hadoop::defaults
{
    $jmx = "${::fqdn}:${jmx_port}"
    $group_name = 'Hadoop.NodeManager'

    # query for metrics from Hadoop DataNode's JVM
    jmxtrans::metrics::jvm { 'hadoop-hdfs-nodemanager':
        jmx                  => $jmx,
        group_prefix         => "${group_name}.",
        outfile              => $outfile,
        ganglia              => $ganglia,
        graphite             => $graphite,
    }


    $nodemanager_objects = $objects ? {
        # if $objects was not set, then use this as the
        # default set of JMX MBean objects to query.
        undef   => [
            {
                'name'          => 'Hadoop:name=JvmMetrics,service=NodeManager',
                'resultAlias'   => "${group_name}.JvmMetrics",
                'attrs'         => {
                    'GcCount'                       => { 'slope' => 'positive' },
                    'GcCountPS MarkSweep'           => { 'slope' => 'positive' },
                    'GcCountPS Scavenge'            => { 'slope' => 'positive' },
                    'GcTimeMillis'                  => { 'slope' => 'both' },
                    'GcTimeMillisPS MarkSweep'      => { 'slope' => 'both' },
                    'GcTimeMillisPS Scavenge'       => { 'slope' => 'both' },
                    'LogError'                      => { 'slope' => 'positive' },
                    'LogFatal'                      => { 'slope' => 'positive' },
                    'LogInfo'                       => { 'slope' => 'both' },
                    'LogWarn'                       => { 'slope' => 'positive' },
                    'MemHeapCommittedM'             => { 'slope' => 'both' },
                    'MemHeapUsedM'                  => { 'slope' => 'both' },
                    'MemNonHeapCommittedM'          => { 'slope' => 'both' },
                    'MemNonHeapUsedM'               => { 'slope' => 'both' },
                    'ThreadsBlocked'                => { 'slope' => 'both' },
                    'ThreadsNew'                    => { 'slope' => 'both' },
                    'ThreadsRunnable'               => { 'slope' => 'both' },
                    'ThreadsTerminated'             => { 'slope' => 'both' },
                    'ThreadsTimedWaiting'           => { 'slope' => 'both' },
                    'ThreadsWaiting'                => { 'slope' => 'both' },
                },

            },
            {
                'name'          => 'Hadoop:name=NodeManagerMetrics,service=NodeManager',
                'resultAlias'   => "${group_name}.NodeManagerMetrics",
                'attrs'         => {
                    'AllocatedContainers'           => { 'slope' => 'both' },
                    'AllocatedGB'                   => { 'slope' => 'both' },
                    'AvailableGB'                   => { 'slope' => 'both' },
                    'ContainersCompleted'           => { 'slope' => 'positive' },
                    'ContainersFailed'              => { 'slope' => 'positive' },
                    'ContainersIniting'             => { 'slope' => 'both' },
                    'ContainersKilled'              => { 'slope' => 'positive' },
                    'ContainersLaunched'            => { 'slope' => 'positive' },
                    'ContainersRunning'             => { 'slope' => 'both' },
                },
            },

            {
                'name' =>          'Hadoop:name=RpcActivityForPort8040,service=NodeManager',
                'resultAlias'   => "${group_name}.RpcActivityForPort8040",
                'attrs'         => {
                    'CallQueueLength'               => { 'slope' => 'both' },
                    'NumOpenConnections'            => { 'slope' => 'both' },
                    'ReceivedBytes'                 => { 'slope' => 'positive' },
                    'RpcAuthenticationFailures'     => { 'slope' => 'positive' },
                    'RpcAuthenticationSuccesses'    => { 'slope' => 'positive' },
                    'RpcAuthorizationFailures'      => { 'slope' => 'positive' },
                    'RpcAuthorizationSuccesses'     => { 'slope' => 'positive' },
                    'RpcProcessingTimeAvgTime'      => { 'slope' => 'both' },
                    'RpcProcessingTimeNumOps'       => { 'slope' => 'positive' },
                    'RpcQueueTimeAvgTime'           => { 'slope' => 'both' },
                    'RpcQueueTimeNumOps'            => { 'slope' => 'positive' },
                    'SentBytes'                     => { 'slope' => 'positive' },
                },
            },

            {
                'name' =>          'Hadoop:name=RpcActivityForPort8041,service=NodeManager',
                'resultAlias'   => "${group_name}.RpcActivityForPort8041",
                'attrs'         => {
                    'CallQueueLength'               => { 'slope' => 'both' },
                    'NumOpenConnections'            => { 'slope' => 'both' },
                    'ReceivedBytes'                 => { 'slope' => 'both' },
                    'RpcAuthenticationFailures'     => { 'slope' => 'both' },
                    'RpcAuthenticationSuccesses'    => { 'slope' => 'both' },
                    'RpcAuthorizationFailures'      => { 'slope' => 'both' },
                    'RpcAuthorizationSuccesses'     => { 'slope' => 'both' },
                    'RpcProcessingTimeAvgTime'      => { 'slope' => 'both' },
                    'RpcProcessingTimeNumOps'       => { 'slope' => 'positive' },
                    'RpcQueueTimeAvgTime'           => { 'slope' => 'both' },
                    'RpcQueueTimeNumOps'            => { 'slope' => 'positive' },
                    'SentBytes'                     => { 'slope' => 'positive' },
                },
            },

            {
                'name' =>          'Hadoop:name=RpcDetailedActivityForPort8041,service=NodeManager',
                'resultAlias'   => "${group_name}.RpcDetailedActivityForPort8041",
                'attrs'         => {
                    'StartContainerAvgTime'         => { 'slope' => 'both' },
                    'StartContainerNumOps'          => { 'slope' => 'positive' },
                    'StopContainerAvgTime'          => { 'slope' => 'both' },
                    'StopContainerNumOps'           => { 'slope' => 'positive' },

                },
            },

            {
                'name' =>          'Hadoop:name=ShuffleMetrics,service=NodeManager',
                'resultAlias'   => "${group_name}.ShuffleMetrics",
                'attrs'         => {
                    'ShuffleConnections'            => { 'slope' => 'both' },
                    'ShuffleOutputBytes'            => { 'slope' => 'positive' },
                    'ShuffleOutputsFailed'          => { 'slope' => 'positive' },
                    'ShuffleOutputsOK'              => { 'slope' => 'positive' },
                },
            },

        ],

        # else use $objects
        default => $objects,
    }

    # query for jmx metrics
    jmxtrans::metrics { "hadoop-yarn-nodemanager-${::hostname}-${jmx_port}":
        jmx                  => $jmx,
        outfile              => $outfile,
        ganglia              => $ganglia,
        ganglia_group_name   => $group_name,
        graphite             => $graphite,
        graphite_root_prefix => $group_name,
        objects              => $nodemanager_objects,
    }
}