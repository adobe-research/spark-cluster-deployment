node default {
  class { 'spark::master':
    worker_mem => '22g'
  }
}
