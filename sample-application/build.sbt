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
