# Puppet module for Spark (0.9.0)

Puppet module to install Spark (0.9.0) on your Hadoop cluster.


Unfortunately no Debian packages are available for Spark, and the pre-compiled Spark versions are not compatible with CDH 4.4.0. 
Therefore I built the Spark incubator version 0.9.0 and included the entire dist directory in the puppet module.

If you want to deploy another version of Spark use the following code to compile (e.g. older Spark 0.8.0):


```bash
wget https://github.com/apache/incubator-spark/archive/v0.8.0-incubating.tar.gz
tar xvf v0.8.0-incubating.tar.gz
cd incubator-spark-0.8.0-incubating/
./make-distribution.sh --hadoop 2.0.0-cdh4.4.0
cp conf/log4j.properties.template dist/conf/log4j.properties

# Replace the standard distribution with the one you just compiled:
rm -rf /etc/puppet/modules/spark/files/spark
cp -r dist /etc/puppet/modules/spark/files/spark

```

*Note: Spark 0.8.0 does not compile with YARN enabled against YARN CDH4.4.0.*


### Dependencies not made explicit in the module itself:


- Oracle Java 6 (7 for Spark 0.9.0+) installed on all nodes (requirement of Spark).
- Apache HDFS should be installed (The CDH4 versions included in: https://github.com/wikimedia/puppet-cdh4 ).
- OS should be Ubuntu/Debian for package dependencies.

### Usage:


On the master node:
```puppet
class {'spark::master':
    worker_mem => 'worker memory e.g. 60g',
    require => [
        Class['your::class::that::ensures::java::is::installed'], 
        Class['cdh4::hadoop']
    ],
}
```

On the worker nodes:
```puppet
class {'spark::worker':
    master => $master_fqdn,
    memory => 'worker memory e.g. 60g',
    require => [
        Class['your::class::that::ensures::java::is::installed'], 
        Class['cdh4::hadoop']
    ],
}
```
