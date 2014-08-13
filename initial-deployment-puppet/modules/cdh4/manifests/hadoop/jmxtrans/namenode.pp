# == Class cdh4::hadoop::jmxtrans::namenode
# Sets up a jmxtrans instance for a Hadoop NameNode
# running on the current host.
# Note: This requires the jmxtrans puppet module found at
# https://github.com/wikimedia/puppet-jmxtrans.
#
# == Parameters
# $jmx_port      - NameNode JMX port.  Default: 9980
# $ganglia       - Ganglia host:port
# $graphite      - Graphite host:port
# $outfile       - outfile to which Kafka stats will be written.
# $objects       - objects parameter to pass to jmxtrans::metrics.  Only use
#                  this if you need to override the default ones that this
#                  class provides.
#
# == Usage
# class { 'cdh4::hadoop::jmxtrans::namenode':
#     ganglia => 'ganglia.example.org:8649'
# }
#
class cdh4::hadoop::jmxtrans::namenode(
    $jmx_port       = $cdh4::hadoop::defaults::namenode_jmxremote_port,
    $ganglia        = undef,
    $graphite       = undef,
    $outfile        = undef,
    $objects        = undef,
) inherits cdh4::hadoop::defaults
{
    $jmx = "${::fqdn}:${jmx_port}"
    $group_name = 'Hadoop.NameNode'

    # query for metrics from Hadoop NameNode's JVM
    jmxtrans::metrics::jvm { 'hadoop-hdfs-namenode':
        jmx                  => $jmx,
        group_prefix         => "${group_name}.",
        outfile              => $outfile,
        ganglia              => $ganglia,
        graphite             => $graphite,
    }

    $namenode_objects = $objects ? {
        # if $objects was not set, then use this as the
        # default set of JMX MBean objects to query.
        undef   => [
            {
                'name'          => 'Hadoop:name=FSNamesystem,service=NameNode',
                'resultAlias'   => "${group_name}.FSNamesystem",
                'attrs'         => {
                    'BlockCapacity'                      => { 'slope' => 'both' },
                    'BlocksTotal'                        => { 'slope' => 'both' },
                    'CapacityRemainingGB'                => { 'slope' => 'both' },
                    'CapacityTotalGB'                    => { 'slope' => 'both' },
                    'CapacityUsedGB'                     => { 'slope' => 'both' },
                    'CorruptBlocks'                      => { 'slope' => 'both' },
                    'ExcessBlocks'                       => { 'slope' => 'both' },
                    'ExpiredHeartbeats'                  => { 'slope' => 'both' },
                    'FilesTotal'                         => { 'slope' => 'both' },
                    'LastCheckpointTime'                 => { 'slope' => 'both' },
                    'LastWrittenTransactionId'           => { 'slope' => 'both' },
                    'MillisSinceLastLoadedEdits'         => { 'slope' => 'both' },
                    'MissingBlocks'                      => { 'slope' => 'both' },
                    'PendingDataNodeMessageCount'        => { 'slope' => 'both' },
                    'PendingDeletionBlocks'              => { 'slope' => 'both' },
                    'PendingReplicationBlocks'           => { 'slope' => 'both' },
                    'PostponedMisreplicatedBlocks'       => { 'slope' => 'both' },
                    'ScheduledReplicationBlocks'         => { 'slope' => 'both' },
                    'TotalFiles'                         => { 'slope' => 'both' },
                    'TotalLoad'                          => { 'slope' => 'both' },
                    'TransactionsSinceLastCheckpoint'    => { 'slope' => 'both' },
                    'TransactionsSinceLastLogRoll'       => { 'slope' => 'both' },
                    'UnderReplicatedBlocks'              => { 'slope' => 'both' },
                    'tag.HAState'                        => { 'slope' => 'both' },
                },
            },


            {
                'name'          => 'Hadoop:name=FSNamesystemState,service=NameNode',
                'resultAlias'   => "${group_name}.FSNamesystemState",
                'attrs'         => {
                    'BlocksTotal'                        => { 'slope' => 'both' },
                    'CapacityRemaining'                  => { 'slope' => 'both' },
                    'CapacityTotal'                      => { 'slope' => 'both' },
                    'CapacityUsed'                       => { 'slope' => 'both' },
                    'FSState'                            => { 'slope' => 'both' },
                    'FilesTotal'                         => { 'slope' => 'both' },
                    'NumDeadDataNodes'                   => { 'slope' => 'both' },
                    'NumLiveDataNodes'                   => { 'slope' => 'both' },
                    'PendingReplicationBlocks'           => { 'slope' => 'both' },
                    'ScheduledReplicationBlocks'         => { 'slope' => 'both' },
                    'TotalLoad'                          => { 'slope' => 'both' },
                    'UnderReplicatedBlocks'              => { 'slope' => 'both' },

                },
            },

            {
                'name'          => 'Hadoop:name=JvmMetrics,service=NameNode',
                'resultAlias'   => "${group_name}.JvmMetrics",
                'attrs'         => {
                    'GcCount'                            => { 'slope' => 'positive' },
                    'GcCountPS MarkSweep'                => { 'slope' => 'positive' },
                    'GcCountPS Scavenge'                 => { 'slope' => 'positive' },
                    'GcTimeMillis'                       => { 'slope' => 'both' },
                    'GcTimeMillisPS MarkSweep'           => { 'slope' => 'both' },
                    'GcTimeMillisPS Scavenge'            => { 'slope' => 'both' },
                    'LogError'                           => { 'slope' => 'positive' },
                    'LogFatal'                           => { 'slope' => 'positive' },
                    'LogInfo'                            => { 'slope' => 'both' },
                    'LogWarn'                            => { 'slope' => 'positive' },
                    'MemHeapCommittedM'                  => { 'slope' => 'both' },
                    'MemHeapUsedM'                       => { 'slope' => 'both' },
                    'MemNonHeapCommittedM'               => { 'slope' => 'both' },
                    'MemNonHeapUsedM'                    => { 'slope' => 'both' },
                    'ThreadsBlocked'                     => { 'slope' => 'both' },
                    'ThreadsNew'                         => { 'slope' => 'both' },
                    'ThreadsRunnable'                    => { 'slope' => 'both' },
                    'ThreadsTerminated'                  => { 'slope' => 'both' },
                    'ThreadsTimedWaiting'                => { 'slope' => 'both' },
                    'ThreadsWaiting'                     => { 'slope' => 'both' },
                },

            },

            {
                'name'          => 'Hadoop:name=NameNodeActivity,service=NameNode',
                'resultAlias'   => "${group_name}.NameNodeActivity",
                'attrs'         => {
                    'AddBlockOps'                        => { 'slope' => 'positive' },
                    'BlockReportAvgTime'                 => { 'slope' => 'both' },
                    'BlockReportNumOps'                  => { 'slope' => 'positive' },
                    'CreateFileOps'                      => { 'slope' => 'positive' },
                    'CreateSymlinkOps'                   => { 'slope' => 'positive' },
                    'DeleteFileOps'                      => { 'slope' => 'positive' },
                    'FileInfoOps'                        => { 'slope' => 'positive' },
                    'FilesAppended'                      => { 'slope' => 'positive' },
                    'FilesCreated'                       => { 'slope' => 'positive' },
                    'FilesDeleted'                       => { 'slope' => 'positive' },
                    'FilesInGetListingOps'               => { 'slope' => 'positive' },
                    'FilesRenamed'                       => { 'slope' => 'positive' },
                    'FsImageLoadTime'                    => { 'slope' => 'positive' },
                    'GetAdditionalDatanodeOps'           => { 'slope' => 'positive' },
                    'GetBlockLocations'                  => { 'slope' => 'positive' },
                    'GetLinkTargetOps'                   => { 'slope' => 'positive' },
                    'GetListingOps'                      => { 'slope' => 'positive' },
                    'SafeModeTime'                       => { 'slope' => 'positive' },
                    'SyncsAvgTime'                       => { 'slope' => 'both' },
                    'SyncsNumOps'                        => { 'slope' => 'positive' },
                    'TransactionsAvgTime'                => { 'slope' => 'both' },
                    'TransactionsBatchedInSync'          => { 'slope' => 'both' },
                    'TransactionsNumOps'                 => { 'slope' => 'positive' },
                },

            },

            {
                'name'          => 'Hadoop:name=NameNodeInfo,service=NameNode',
                'resultAlias'   => "${group_name}.NameNodeInfo",
                'attrs'         => {
                    'BlockPoolUsedSpace'                 => { 'slope' => 'both' },
                    'Free'                               => { 'slope' => 'both' },
                    'NonDfsUsedSpace'                    => { 'slope' => 'both' },
                    'NumberOfMissingBlocks'              => { 'slope' => 'both' },
                    'PercentBlockPoolUsed'               => { 'slope' => 'both' },
                    'PercentRemaining'                   => { 'slope' => 'both' },
                    'PercentUsed'                        => { 'slope' => 'both' },
                    'Safemode'                           => { 'slope' => 'both' },
                    'Threads'                            => { 'slope' => 'both' },
                    'Total'                              => { 'slope' => 'both' },
                    'TotalBlocks'                        => { 'slope' => 'both' },
                    'TotalFiles'                         => { 'slope' => 'both' },
                    'Used'                               => { 'slope' => 'both' },
                    'Version'                            => { 'slope' => 'both' },
                },
            },

            {
                'name'          => 'Hadoop:name=RpcActivityForPort8020,service=NameNode',
                'resultAlias'   => "${group_name}.RpcActivityForPort8020",
                'attrs'         => {
                    'CallQueueLength'                    => { 'slope' => 'both' },
                    'NumOpenConnections'                 => { 'slope' => 'both' },
                    'ReceivedBytes'                      => { 'slope' => 'positive' },
                    'RpcAuthenticationFailures'          => { 'slope' => 'positive' },
                    'RpcAuthenticationSuccesses'         => { 'slope' => 'positive' },
                    'RpcAuthorizationFailures'           => { 'slope' => 'positive' },
                    'RpcAuthorizationSuccesses'          => { 'slope' => 'positive' },
                    'RpcProcessingTimeAvgTime'           => { 'slope' => 'both' },
                    'RpcProcessingTimeNumOps'            => { 'slope' => 'positive' },
                    'RpcQueueTimeAvgTime'                => { 'slope' => 'both' },
                    'RpcQueueTimeNumOps'                 => { 'slope' => 'positive' },
                    'SentBytes'                          => { 'slope' => 'positive' },
                },
            },
        ],
        # else use $objects
        default => $objects,
    }

    # query for jmx metrics
    jmxtrans::metrics { "hadoop-hdfs-namenode-${::hostname}-${jmx_port}":
        jmx                  => $jmx,
        outfile              => $outfile,
        ganglia              => $ganglia,
        ganglia_group_name   => $group_name,
        graphite             => $graphite,
        graphite_root_prefix => $group_name,
        objects              => $namenode_objects,
    }
}