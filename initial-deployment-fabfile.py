# initial-deployment-fabfile.py
# Bootstraps servers and installs HDFS and Spark master and workers as
# services on the cluster.
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
from fabric.contrib.project import rsync_project
from fabric.contrib.files import append, contains, exists

import os
import yaml

script_dir = os.path.dirname(__file__)
with open(script_dir+"/config.yaml", "r") as f:
  config = yaml.load(f)

env.roledefs['master'] = config['master']
env.roledefs['workers'] = config['workers']
env.roledefs['all'] = config['all']
env.use_ssh_config = True

deployDir = "initial-deployment-puppet"

def puppetApply(manifest):
  sudo('puppet apply --modulepath ' + deployDir + '/modules ' +
    deployDir + '/manifests/' + manifest)

def rsync():
  rsync_project(
    remote_dir=deployDir,
    local_dir=script_dir+"/initial-deployment-puppet/",
    extra_opts='--delete'
  )

@task
@roles('master')
def startSparkMaster():
  rsync()
  puppetApply('spark-master.pp')

@task
@roles('workers')
@parallel
def startSparkWorkers():
  rsync()
  puppetApply('spark-worker.pp')

@task
@roles('master')
def stopSparkMaster():
  with settings(warn_only=True):
    sudo("/sbin/initctl stop spark-master")

@task
@roles('workers')
@parallel
def stopSparkWorkers():
  with settings(warn_only=True):
    sudo("/sbin/initctl stop spark-worker")

@task
@roles('master')
def startHdfsMaster():
  rsync()
  puppetApply('hdfs-master.pp')

@task
@roles('workers')
@parallel
def startHdfsWorkers():
  rsync()
  puppetApply('hdfs-worker.pp')

@task
@roles('master')
def stopHdfsMaster():
  sudo("/sbin/service hadoop-hdfs-namenode stop")
  sudo("/sbin/service hadoop-0.20-mapreduce-jobtracker stop")
  sudo("/sbin/service hadoop-mapreduce-historyserver stop")
  sudo("/sbin/service hadoop-yarn-nodemanager stop")
  sudo("/sbin/service hadoop-yarn-resourcemanager stop")

@task
@roles('workers')
@parallel
def stopHdfsWorkers():
  sudo("/sbin/service hadoop-hdfs-datanode stop")

@task
@roles('all')
@parallel
def init():
  # === Software and config.
  # CentOS.
  sudo('yum install java-1.7.0-openjdk-devel make puppet zsh -y')

  sudo('chsh -s /bin/zsh amos')
  if not exists('.dotfiles'):
    with settings(warn_only=True):
      run('git clone --recursive http://github.com/bamos/dotfiles.git .dotfiles')
      run('./.dotfiles/bootstrap.sh -n')
  with cd(".dotfiles"):
    run('git pull') # Keep dotfiles synchronized.

  for server in env.roledefs['all']:
    if not exists('.ssh/config'):
      run('touch .ssh/config; chmod 600 .ssh/config')
    if not contains('.ssh/config', server):
      append('.ssh/config',
          'Host ' + server + '\n  HostName ' + server + '.or1')

  #sudo("rm -rf /raid/hadoop")
  sudo("mkdir -p /raid/hadoop")
