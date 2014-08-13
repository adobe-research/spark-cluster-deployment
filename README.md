# Spark Cluster Deployment

| ![](https://github.com/adobe-research/spark-cluster-deployment/raw/master/images/initial-deployment-2.png) | ![](https://github.com/adobe-research/spark-cluster-deployment/raw/master/images/application-deployment-1.png) |
|---|---|

[Apache Spark][spark] is a research project for distributed computing
which interacts with HDFS and heavily utilizes in-memory caching.
Spark 1.0.0 can be deployed to traditional cloud and job management services
such as [EC2][spark-ec2], [Mesos][spark-mesos], or
[Yarn][spark-yarn].
Further, Spark's [standalone cluster][spark-standalone] mode enables
Spark to run on other servers without installing other
job management services.

However, configuring and submitting applications to a Spark 1.0.0 standalone
cluster currently requires files to be synchronized across the entire cluster,
including the Spark installation directory.
**This project utilizes [Fabric][fabric] and [Puppet][puppet] to further automate
the Spark standalone cluster.**
The Puppet scripts are MIT-licensed from
[stefanvanwouw/puppet-spark][puppet-spark] and
[wikimedia/puppet-cdh4][puppet-cdh4].

**Initial deployment** installs HDFS and Spark on every server in the
cluster and **application deployment** submits Spark application
JAR's to the cluster.
An application to test deployment is provided in `sample-app`.

These scripts have been tested in CentOS 6.5 with
Spark 1.0.0 and Hadoop 2.0.0-cdh4.7.0.

```
> cat /etc/centos-release
CentOS release 6.5 (Final)

> hadoop version
Hadoop 2.0.0-cdh4.7.0

> cat /usr/lib/spark/RELEASE
Spark 1.0.0 built for Hadoop 2.0.0-cdh4.7.0
```

# Configuration
0. Merge the prebuilt Spark library for Hadoop 2.0.0 CDH 4.7.0
   with the following commands.
   As described in [puppet-spark][puppet-spark], the prebuilt
   library is necessary because Spark is not built for cdh 4.7.0.

   ```
   cd initial-deployment-puppet/modules/spark/files/spark/lib
   cat spark-assembly.{1,2} > spark-examples-1.0.0-hadoop2.0.0-cdh4.7.0.jar
   rm spark-assembly.*
   ```

1. Copy `config.yaml.tmpl` to `config.yaml` and set the master and
   worker servers.
   Ensure they can be accessed without a password [using SSH keys][ssh-keys].
2. The Python dependencies are included in `requirements.txt` and can
   be installed using `pip` with `pip2.7 install -r requirements.txt`.
3. Modify the `init` method of `initial-deployment-fabfile.py`
   to `init` for your OS to install the Java JDK 1.7,
   make, and puppet and any other configuration all servers should have.
   The existing `init` configuration is for CentOS 6.5.
4.  Add server names and memory allocations to
   `initial-deployment-puppet/manifests` after copying the `tmpl` files.
   The master should match the master in `servers.yaml`.

# Shell functions and aliases
Using Fabric for deployment requires a configuration file named `fabfile.py`
in the current directory or a `-f` parameter specifying the location
of the configuration file.
`env.sh` provides the following shell functions and aliases to interact
with Fabric.

The commands provided in `env.sh` can be used by adding the following
line to `.bashrc` or `.zshrc` or by sourcing it in your current shell.

```Bash
source <spark-cluster-deployment>/env.sh
```

```Bash
# Initial deployment shell aliases/functions.
function spark-init() {
  fab -f $DEPLOY_DIR/initial-deployment-fabfile.py $*
}

alias si='spark-init'
alias si-list='spark-init -list'
alias si-start-hm='spark-init startHdfsMaster'
alias si-start-hw='spark-init startHdfsWorkers'
alias si-start-sm='spark-init startSparkMaster'
alias si-start-sw='spark-init startSparkWorkers'
alias si-stop-hm='spark-init stopHdfsMaster'
alias si-stop-hw='spark-init stopHdfsWorkers'
alias si-stop-sm='spark-init stopSparkMaster'
alias si-stop-sw='spark-init stopSparkWorkers'

# Application deployment shell aliases/functions.
function spark-submit() {
  fab -f $DEPLOY_DIR/application-deployment-fabfile.py $*
}

alias ss='spark-submit'
alias ss-list='spark-submit -list'
alias ss-sy='spark-submit sync'
alias ss-st='spark-submit start'
alias ss-a='spark-submit assembly'
alias ss-ss='spark-submit sync start'
alias ss-o='spark-submit getOutput'
alias ss-k='spark-submit kill'
```

# Initial Deployment
The Puppet and Fabric scripts for the initial deployment bootstraps
servers and installs HDFS and Spark master and workers as services
on the cluster.

![Initialization.](https://github.com/adobe-research/spark-cluster-deployment/raw/master/images/initial-deployment-1.png)
![Start Spark and HDFS masters.](https://github.com/adobe-research/spark-cluster-deployment/raw/master/images/initial-deployment-2.png)
![Start Spark and HDFS workers.](https://github.com/adobe-research/spark-cluster-deployment/raw/master/images/initial-deployment-3.png)

## Services.
Spark and HDFS should run as services so they can be
monitored and automatically started.
Spark workers will crash if an uncaught exception occurs in a
program, even by the Spark libraries!
HDFS uses [SysV][sysv] init services by default and are left
unmodified.
The [puppet-spark][puppet-spark] [upstart][upstart] scripts for
Spark have been modified to restart Spark workers when their
processes terminate.

## Scripts.

Use `si-list` to obtain a list of the available initial deployment commands.

```
> si-list

Available commands:

    init
    startHdfsMaster
    startHdfsWorkers
    startSparkMaster
    startSparkWorkers
    stopHdfsMaster
    stopHdfsWorkers
    stopSparkMaster
    stopSparkWorkers
```

For example, to configure, install, and run Hadoop and Spark.

```
spark-init init
spark-init startHdfsMaster startHdfsWorkers startSparkMaster startSparkWorkers
```

To stop HDFS:

```
spark-init stopHdfsWorkers stopHdfsMaster
```

To stop Spark:

```
spark-init stopSparkWorkers stopSparkMaster
```

## Connecting to Spark and HDFS

If the deployment succeeds, Spark should be started with a web interface
at `spark_master_hostname:8080`, and the web interface for the HDFS
namenode is available at `spark_master_hostname:50070`.
Spark can be accessed at `spark://spark_master_hostname:7077` and
HDFS can be accessed at `hdfs://spark_master_hostname:8020`.

# Application Deployment

Deploying applications to a Spark cluster requires application
JAR files to be distributed across every node on the cluster,
and provides no way of obtaining the output from the command line.
To ease the process of developing and deploying a Spark application,
the Fabric script `application-deployment-fabfile.py` provides
this functionality.

![Application deployment.](https://github.com/adobe-research/spark-cluster-deployment/raw/master/images/application-deployment-1.png)

## Example Usage
This runs the example Spark application located in `sample-application`,
which squares a `Seq` of numbers.

Build the application with `ss assembly`, which uses Fabric
and pipes the output of `sbt assembly` to `assembly.log`.
If this succeeds, syncronize the fat JAR to all servers
and start the application.
The Spark master will select a worker to run the driver on.

```
> ss assembly && ss sync && ss start
[localhost] local: sbt assembly &> assembly.log

Done.
[node20] Executing task 'sync'
[node21] Executing task 'sync'
[node22] Executing task 'sync'
[node23] Executing task 'sync'
[node24] Executing task 'sync'
[node25] Executing task 'sync'
[node24] put: target/scala-2.10//ExampleApp.jar -> /tmp/ExampleApp.jar
[node22] put: target/scala-2.10//ExampleApp.jar -> /tmp/ExampleApp.jar
[node25] put: target/scala-2.10//ExampleApp.jar -> /tmp/ExampleApp.jar
[node23] put: target/scala-2.10//ExampleApp.jar -> /tmp/ExampleApp.jar
[node20] put: target/scala-2.10//ExampleApp.jar -> /tmp/ExampleApp.jar
[node21] put: target/scala-2.10//ExampleApp.jar -> /tmp/ExampleApp.jar

Done.
[node20] Executing task 'start'
[node20] sudo: /usr/lib/spark/bin/spark-submit  --class com.adobe.ExampleApp --master spark://spark_master_hostname:7077 --deploy-mode cluster /tmp//ExampleApp.jar

DriverID: driver-20140731140016-0000
Status: RUNNING
DriverServer: node20

Done.
Disconnecting from node20... done.
```

Next, use `getOutput` to get the driver stdout and stderr.

```
> ss getOutput
[localhost] local: scp node20:/raid/spark-work/driver-20140731140016-0000/stdout stdout.txt
stdout                                             100%   39     0.0KB/s   00:00
[localhost] local: scp node20:/raid/spark-work/driver-20140731140016-0000/stderr stderr.txt
stderr                                             100%   20KB  19.5KB/s   00:00

Done.
```

```
> cat stdout.txt
Nums: 1, 2, 4, 8
Squares: 1, 4, 16, 64
```

## Configuring Applications
The `sample-application` directory illustrates the usage of
the application deployment Fabric scripts.

Applications should use [sbt][sbt] for building the application with
the [sbt-assembly][sbt-assembly] plugin to create a fat JAR.

`project/assembly.sbt` adds the assembly plugin.

```Scala
addSbtPlugin("com.eed3si9n" % "sbt-assembly" % "0.11.2")
```

`build.sbt` contains `sbt` settings and dependencies.

```Scala
import AssemblyKeys._

assemblySettings

jarName in assembly := "ExampleApp.jar"

name := "Example App"

version := "1.0"

scalaVersion := "2.10.3"

// Load "provided" libraries with `sbt run`.
run in Compile <<= Defaults.runTask(
  fullClasspath in Compile, mainClass in (Compile, run), runner in (Compile, run)
)

libraryDependencies ++= Seq(
  "org.apache.spark" %% "spark-core" % "1.0.0" % "provided",
  "org.slf4j" % "slf4j-simple" % "1.7.7" // Logging.
)

resolvers += "Akka Repository" at "http://repo.akka.io/releases/"
```

The Fabric scripts from from application specific `config.yaml` files.

```Yaml
jar: ExampleApp.jar
local_jar_dir: target/scala-2.10/
remote_jar_dir: /tmp/
main_class: com.adobe.ExampleApp
remote_spark_dir: /usr/lib/spark
spark_master: spark://spark_master_hostname:7077
spark_work: /raid/spark-work
```

## Initializing A Spark Context
The Spark context should attach to the standalone cluster
and use the fat JAR deployed to all nodes as follows.

```Scala
val conf = new SparkConf()
  .setAppName("ExampleApp")
  .setMaster("spark://spark_master_hostname.com:7077")
  .setSparkHome("/usr/lib/spark")
  .setJars(Seq("/tmp/ExampleApp.jar"))
  .set("spark.executor.memory", "10g")
  .set("spark.cores.max", "4")
val sc = new SparkContext(conf)
```

# Licensing
The Puppet scripts are MIT-licensed from
[stefanvanwouw/puppet-spark][puppet-spark] and
[wikimedia/puppet-cdh4][puppet-cdh4].
Diagrams are available in the public domain from
[bamos/beamer-snippets][beamer-snippets].
Other portions are copyright 2014 Adobe Systems Incorporated
under the Apache 2 license, and a copy is provided in `LICENSE`.

[fabric]: http://www.fabfile.org/
[puppet]: http://puppetlabs.com
[spark]: http://spark.apache.org
[puppet-spark]: https://github.com/stefanvanwouw/puppet-spark
[puppet-cdh4]: https://github.com/wikimedia/puppet-cdh4

[ssh-keys]: https://www.digitalocean.com/community/tutorials/how-to-set-up-ssh-keys--2

[spark-ec2]: http://spark.apache.org/docs/1.0.0/ec2-scripts.html
[spark-mesos]: http://spark.apache.org/docs/1.0.0/running-on-mesos.html
[spark-yarn]: http://spark.apache.org/docs/1.0.0/running-on-yarn.html
[spark-standalone]: http://spark.apache.org/docs/1.0.0/spark-standalone.html
[beamer-snippets]: https://github.com/bamos/beamer-snippets

[sysv]: http://en.wikipedia.org/wiki/Init#SysV-style
[upstart]: http://upstart.ubuntu.com/cookbook/

[sbt]: http://www.scala-sbt.org/
[sbt-assembly]: https://github.com/sbt/sbt-assembly
