///////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2014 Adobe Systems Incorporated. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
///////////////////////////////////////////////////////////////////////////

package com.adobe

import org.apache.spark.SparkConf
import org.apache.spark.SparkContext
import org.apache.spark.SparkContext._

import java.io.{File,PrintWriter}

object ExampleApp {
  def main(args: Array[String]) {
    val conf = new SparkConf()
      .setAppName("ExampleApp")
      .setMaster("spark://spark_master_hostname:7077")
      .setSparkHome("/usr/lib/spark")
      .setJars(Seq("/tmp/ExampleApp.jar"))
      .set("spark.executor.memory", "10g")
      .set("spark.cores.max", "4")
    val sc = new SparkContext(conf)
    val nums = sc.parallelize(Seq(1,2,4,8))
    val squares = nums.map{case num => num*num}
    println("Nums: " + nums.collect().mkString(", "))
    println("Squares: " + squares.collect().mkString(", "))
    sc.stop()
  }
}
