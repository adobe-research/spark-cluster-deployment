# fabfile.py
# TODO - Description.
#
###########################################################################
##
## Copyright (c) 2014 Adobe Systems Incorporated. All rights reserved.
##
## Licensed under the Apache License, Version 2.0 (the "License");
## you may not use this file except in compliance with the License.
## You may obtain a copy of the License at
##
## http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.
##
###########################################################################

from fabric.api import *
from textwrap import dedent, wrap
import io
import re
import pickle
import sys
import os
import yaml

script_dir = os.path.dirname(__file__)
with open(script_dir+"/config.yaml", "r") as f:
  config = yaml.load(f)
if os.path.isfile('config.yaml'):
  with open('config.yaml', 'r') as f:
    config.update(yaml.load(f))
else:
  print("Error: Current directory must have local application config.")
  sys.exit(-1)

env.roledefs['master'] = config['master']
env.roledefs['workers'] = config['workers']
env.roledefs['all'] = config['all']
env.use_ssh_config = True

@task
def assembly():
  local("sbt assembly &> assembly.log")

@task
def sync():
  # put(config['local_jar_dir'] + '/' + config['jar'], config['remote_jar_dir'])
  for server in config['all']:
    local("rsync -azrv --progress {}/{} {}:/{}".format(
      config['local_jar_dir'],
      config['jar'],
      server,
      config['remote_jar_dir']
    ))

@task
@roles('master')
def start():
  outIO = io.BytesIO(); errIO = io.BytesIO()
  sudo(' '.join([
    config['remote_spark_dir'] + '/bin/spark-submit ',
    '--class', config['main_class'], '--master', config['spark_master'],
    '--deploy-mode', 'cluster', config['remote_jar_dir'] + '/' + config['jar']
  ]), stdout=outIO, stderr=errIO)
  outIO.seek(0); errIO.seek(0)
  outStr = outIO.read()
  driverRe = re.search("State of (driver-\d*-\d*) is (\S*)", outStr)
  driverId = driverRe.group(1)
  status = driverRe.group(2)
  print("  DriverID: " + driverId)
  print("  Status: " + status)
  if status == "ERROR":
    msg = """
    The error state occurs when the Spark Master rejects the job,
    which is likely due to a misconfiguration in the Spark context
    of your application.
    Once checking your Spark context for accuracy, next ssh into the node
    that failed and go to Spark work directory, which contains
    the output for Spark applicaitons and drivers.
    Check stderr and stdout in the driver and application directories.
    """
    print(dedent(msg))
  elif status == "RUNNING":
    driverServerRe = re.search("Driver running on (\S*):\d* ", outStr)
    driverServer = driverServerRe.group(1)
    print("  DriverServer: " + driverServer)
    with open('lastJobStarted.pickle', 'wb') as f:
      pickle.dump({
        'driverId': driverId,
        'driverServer': driverServer
      }, f)
  else:
    print(status)


@task
@roles('master')
def kill(driverId=None):
  if not driverId:
    try:
      with open('lastJobStarted.pickle', 'rb') as f:
        m = pickle.load(f)
    except IOError as e:
      print("Unable to open lastJobStarted.pickle")
    driverId = m['driverId']
  sudo(' '.join([
    config['remote_spark_dir'] + '/bin/spark-class ',
    "org.apache.spark.deploy.Client kill",
    config['spark_master'],
    driverId
  ]))

@task
def getOutput(driverId=None,driverServer=None):
  if not driverId:
    try:
      with open('lastJobStarted.pickle', 'rb') as f:
        m = pickle.load(f)
    except IOError as e:
      print("Unable to open lastJobStarted.pickle")
      sys.exit(-1)
    driverId = m['driverId']
    driverServer = m['driverServer']
  local("scp " +
    driverServer + ":" + config['spark_work'] + "/" + driverId +
      "/stdout " + "stdout.txt")
  local("scp " +
    driverServer + ":" + config['spark_work'] + "/" + driverId +
      "/stderr " + "stderr.txt")
