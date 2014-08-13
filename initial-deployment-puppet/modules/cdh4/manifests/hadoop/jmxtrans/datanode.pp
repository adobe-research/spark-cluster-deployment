# == Class cdh4::hadoop::jmxtrans::datanode
# Sets up a jmxtrans instance for a Hadoop ResourceManager
# running on the current host.
# Note: This requires the jmxtrans puppet module found at
# https://github.com/wikimedia/puppet-jmxtrans.
#
# == Parameters
# $jmx_port      - DataNode JMX port.  Default: 9981
# $ganglia       - Ganglia host:port
# $graphite      - Graphite host:port
# $outfile       - outfile to which Kafka stats will be written.
# $objects       - objects parameter to pass to jmxtrans::metrics.  Only use
#                  this if you need to override the default ones that this
#                  class provides.
#
# == Usage
# class { 'cdh4::hadoop::jmxtrans::datanode':
#     ganglia => 'ganglia.example.org:8649'
# }
#
class cdh4::hadoop::jmxtrans::datanode(
    $jmx_port       = $cdh4::hadoop::defaults::datanode_jmxremote_port,
    $ganglia        = undef,
    $graphite       = undef,
    $outfile        = undef,
    $objects        = undef,
) inherits cdh4::hadoop::defaults
{
    $jmx = "${::fqdn}:${jmx_port}"
    $group_name = 'Hadoop.DataNode'

    # query for metrics from Hadoop DataNode's JVM
    jmxtrans::metrics::jvm { 'hadoop-yarn-datanode':
        jmx                  => $jmx,
        group_prefix         => "${group_name}.",
        outfile              => $outfile,
        ganglia              => $ganglia,
        graphite             => $graphite,
    }


    $datanode_objects = $objects ? {
        # if $objects was not set, then use this as the
        # default set of JMX MBean objects to query.
        undef   => [
            {
                'name'          =>          'Hadoop:name=DataNodeActivity-analytics1011.eqiad.wmnet-50010,service=DataNode',
                'resultAlias'   => "${group_name}.Activity",
                'attrs'         => {
                    'BlockChecksumOpAvgTime'                     => { 'slope' => 'both' },
                    'BlockChecksumOpNumOps'                      => { 'slope' => 'positive' },
                    'BlockReportsAvgTime'                        => { 'slope' => 'both' },
                    'BlockReportsNumOps'                         => { 'slope' => 'positive' },
                    'BlockVerificationFailures'                  => { 'slope' => 'positive' },
                    'BlocksGetLocalPathInfo'                     => { 'slope' => 'both' },
                    'BlocksRead'                                 => { 'slope' => 'positive' },
                    'BlocksRemoved'                              => { 'slope' => 'positive' },
                    'BlocksReplicated'                           => { 'slope' => 'positive' },
                    'BlocksVerified'                             => { 'slope' => 'positive' },
                    'BlocksWritten'                              => { 'slope' => 'positive' },
                    'BytesRead'                                  => { 'slope' => 'positive' },
                    'BytesWritten'                               => { 'slope' => 'positive' },
                    'CopyBlockOpAvgTime'                         => { 'slope' => 'both' },
                    'CopyBlockOpNumOps'                          => { 'slope' => 'positive' },
                    'FlushNanosAvgTime'                          => { 'slope' => 'both' },
                    'FlushNanosNumOps'                           => { 'slope' => 'positive' },
                    'FsyncCount'                                 => { 'slope' => 'positive' },
                    'FsyncNanosAvgTime'                          => { 'slope' => 'both' },
                    'FsyncNanosNumOps'                           => { 'slope' => 'positive' },
                    'HeartbeatsAvgTime'                          => { 'slope' => 'both' },
                    'HeartbeatsNumOps'                           => { 'slope' => 'positive' },
                    'PacketAckRoundTripTimeNanosAvgTime'         => { 'slope' => 'both' },
                    'PacketAckRoundTripTimeNanosNumOps'          => { 'slope' => 'positive' },
                    'ReadBlockOpAvgTime'                         => { 'slope' => 'both' },
                    'ReadBlockOpNumOps'                          => { 'slope' => 'positive' },
                    'ReadsFromLocalClient'                       => { 'slope' => 'positive' },
                    'ReadsFromRemoteClient'                      => { 'slope' => 'positive' },
                    'ReplaceBlockOpAvgTime'                      => { 'slope' => 'both' },
                    'ReplaceBlockOpNumOps'                       => { 'slope' => 'positive' },
                    'SendDataPacketBlockedOnNetworkNanosAvgTime' => { 'slope' => 'both' },
                    'SendDataPacketBlockedOnNetworkNanosNumOps'  => { 'slope' => 'positive' },
                    'SendDataPacketTransferNanosAvgTime'         => { 'slope' => 'both' },
                    'SendDataPacketTransferNanosNumOps'          => { 'slope' => 'positive' },
                    'VolumeFailures'                             => { 'slope' => 'positive' },
                    'WriteBlockOpAvgTime'                        => { 'slope' => 'both' },
                    'WriteBlockOpNumOps'                         => { 'slope' => 'positive' },
                    'WritesFromLocalClient'                      => { 'slope' => 'both' },
                    'WritesFromRemoteClient'                     => { 'slope' => 'both' },
                 },
            },

            {
                'name'          =>          'Hadoop:name=FSDatasetState-DS-443972865-10.64.36.111-50010-1377634552935,service=DataNode',
                'resultAlias'   => "${group_name}.FSDatasetState",
                'attrs'         => {
                    'Capacity'                                  => { 'slope' => 'both' },
                    'DfsUsed'                                   => { 'slope' => 'both' },
                    'NumFailedVolumes'                          => { 'slope' => 'both' },
                    'Remaining'                                 => { 'slope' => 'both' },
                    'StorageInfo'                               => { 'slope' => 'both' },
                },
            },

            {
                'name' =>          'Hadoop:name=JvmMetrics,service=DataNode',
                'resultAlias'   => "${group_name}.JvmMetrics",
                'attrs'         => {
                    'GcCount'                                   => { 'slope' => 'positive' },
                    'GcCountPS MarkSweep'                       => { 'slope' => 'positive' },
                    'GcCountPS Scavenge'                        => { 'slope' => 'positive' },
                    'GcTimeMillis'                              => { 'slope' => 'both' },
                    'GcTimeMillisPS MarkSweep'                  => { 'slope' => 'both' },
                    'GcTimeMillisPS Scavenge'                   => { 'slope' => 'both' },
                    'LogError'                                  => { 'slope' => 'positive' },
                    'LogFatal'                                  => { 'slope' => 'positive' },
                    'LogInfo'                                   => { 'slope' => 'both' },
                    'LogWarn'                                   => { 'slope' => 'positive' },
                    'MemHeapCommittedM'                         => { 'slope' => 'both' },
                    'MemHeapUsedM'                              => { 'slope' => 'both' },
                    'MemNonHeapCommittedM'                      => { 'slope' => 'both' },
                    'MemNonHeapUsedM'                           => { 'slope' => 'both' },
                    'ThreadsBlocked'                            => { 'slope' => 'both' },
                    'ThreadsNew'                                => { 'slope' => 'both' },
                    'ThreadsRunnable'                           => { 'slope' => 'both' },
                    'ThreadsTerminated'                         => { 'slope' => 'both' },
                    'ThreadsTimedWaiting'                       => { 'slope' => 'both' },
                    'ThreadsWaiting'                            => { 'slope' => 'both' },
                },
            },

            {
                'name' =>          'Hadoop:name=RpcActivityForPort50020,service=DataNode',
                'resultAlias'   => "${group_name}.RpcActivityForPort50020",
                'attrs'         => {
                    'CallQueueLength'                           => { 'slope' => 'both' },
                    'NumOpenConnections'                        => { 'slope' => 'both' },
                    'ReceivedBytes'                             => { 'slope' => 'positive' },
                    'RpcAuthenticationFailures'                 => { 'slope' => 'positive' },
                    'RpcAuthenticationSuccesses'                => { 'slope' => 'positive' },
                    'RpcAuthorizationFailures'                  => { 'slope' => 'positive' },
                    'RpcAuthorizationSuccesses'                 => { 'slope' => 'positive' },
                    'RpcProcessingTimeAvgTime'                  => { 'slope' => 'both' },
                    'RpcProcessingTimeNumOps'                   => { 'slope' => 'positive' },
                    'RpcQueueTimeAvgTime'                       => { 'slope' => 'both' },
                    'RpcQueueTimeNumOps'                        => { 'slope' => 'positive' },
                    'SentBytes'                                 => { 'slope' => 'positive' },

                },
            },
            {
                'name' =>          'Hadoop:name=RpcDetailedActivityForPort50020,service=DataNode',
                'resultAlias'   => "${group_name}.RpcDetailedActivityForPort50020",
                'attrs'         => {
                    'InitReplicaRecoveryAvgTime'                => { 'slope' => 'both' },
                    'InitReplicaRecoveryNumOps'                 => { 'slope' => 'positive' },
                    'UpdateReplicaUnderRecoveryAvgTime'         => { 'slope' => 'both' },
                    'UpdateReplicaUnderRecoveryNumOps'          => { 'slope' => 'positive' },
               },
            },
        ],
        # else use $objects
        default => $objects,
    }

    # query for jmx metrics
    jmxtrans::metrics { "hadoop-hdfs-datanode-${::hostname}-${jmx_port}":
        jmx                  => $jmx,
        outfile              => $outfile,
        ganglia              => $ganglia,
        ganglia_group_name   => $group_name,
        graphite             => $graphite,
        graphite_root_prefix => $group_name,
        objects              => $datanode_objects,
    }
}