Hadoop very conveniently ships with built in Ganglia metrics reporter support.
However, the GangliaContext class uses DatagramSocket instead of MulticastSocket.
This will only work in Ganglia multicast setups where the there is no more than
1 network hop needed to get to the ganglia aggretagor(s) for your multicast group.
See https://issues.apache.org/jira/browse/HADOOP-10181 for more details.

Wikimedia uses a multi row VLAN setup for its Hadoop nodes, and needs a way
to send Hadoop metrics to ganglia in a multicast setup.  Jmxtrans supports
this.  These jmxtrans classes can be included to send a particular Hadoop
service's metrics to Ganglia.

# Usage

On your Hadoop master node:

```puppet
class { 'cdh4::hadoop::jmxtrans::master':
    ganglia => 'ganglia.example.com',
}
```

On your Hadoop worker nodes:
```puppet
class { 'cdh4::hadoop::jmxtrans::worker':
    ganglia => 'ganglia.example.com',
}
```
