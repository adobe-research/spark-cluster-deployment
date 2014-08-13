import "adobe_hadoop"

node default {
  include adobe::hadoop_base
  include cdh4::hadoop::worker
}
