# env.sh
# Source this script for Spark standalone deployment shell functions.
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

DEPLOY_DIR="$( cd "$( dirname "$0" )" && pwd )"
INITIAL_DIR=$DEPLOY_DIR+"/initial-deployment"
APPLICATION_DIR=$DEPLOY_DIR+"/application-deployment"

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
