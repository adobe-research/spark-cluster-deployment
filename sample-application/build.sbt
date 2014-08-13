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
