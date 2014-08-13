class spark::defaults {
    $install_dir     = '/usr/lib/spark'
    $master_port     = 7077
    $web_port        = 8080
    $cores           = undef
    $memory          = undef
    $scratch_dir     = "${install_dir}/work"
}
