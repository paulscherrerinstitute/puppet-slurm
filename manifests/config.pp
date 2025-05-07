# slurm/config.pp
#
# Creates the common configuration files.
#
# For details about the parameters, please refer to the SLURM documentation at https://slurm.schedmd.com/slurm.conf.html
#
# version 20170829
#
# Copyright (c) CERN, 2016-2017
# Authors: - Philippe Ganz <phganz@cern.ch>
#          - Carolina Lindqvist <calindqv@cern.ch>
#          - Pablo Llopis <pablo.llopis@cern.ch>
# License: GNU GPL v3 or later.
#

class slurm::config (
  # DEPRECATRED SETTINGS
  Optional[String] $control_machine = undef,
  Optional[String] $control_addr = $control_machine,
  Optional[String] $backup_controller = undef,
  Optional[String] $backup_addr = $backup_controller,
  # NEW SETTINGS
  Optional[String] $slurmctld_addr = undef,
  Optional[Array]  $slurmctld_host = undef,
  Optional[String] $slurmctld_primary_off_prog = undef,
  Optional[String] $slurmctld_primary_on_prog = undef,
  Optional[Array]  $slurmctld_parameters = undef,
  Integer[0,1] $allow_spec_resources_usage = 0,
  Optional[String] $checkpoint_type = undef,
  Optional[String] $chos_loc = undef,
  Optional[String] $core_spec_plugin = versioncmp($slurm::params::slurm_version, '24.11') >= 0 ? { true => undef, false => 'core_spec/none'},
  String $cpu_freq_def = 'Performance',
  Array[String] $cpu_freq_governors = ['OnDemand','Performance'],
  Enum['NO','YES'] $disable_root_jobs = 'NO',
  Enum['NO','YES','ALL','ANY'] $enforce_part_limits = 'NO',
  Optional[String] $ext_sensors_type = versioncmp($slurm::params::slurm_version, '23.11') >= 0 ? { true => undef, false => 'ext_sensors/none' },
  Optional[Integer[0]] $ext_sensors_freq = versioncmp($slurm::params::slurm_version, '23.11') >= 0 ? { true => undef, false => 0 },
  Integer[1] $first_job_id = 1,
  Integer[1] $max_job_id = 999999,
  Optional[Array[String]] $federation_parameters = undef,
  Optional[Array[String]] $gres_types = undef,
  Integer[0,1] $group_update_force = 0,
  Optional[String] $job_checkpoint_dir = undef,
  String $job_container_type = 'job_container/none',
  Integer[0,1] $job_file_append = 0,
  Integer[0,1] $job_requeue = 0,
  Optional[Array[String]] $job_submit_plugins = undef,
  Integer[0,1] $kill_on_bad_exit = 0,
  String $launch_type = 'launch/slurm',
  Optional[Array[String]] $launch_parameters = undef,
  Optional[Array[String]] $licenses = undef,
  Optional[String] $node_features_plugins = undef,
  String $mail_prog = '/bin/mail',
  Optional[String] $mail_domain = undef,
  Optional[Integer[1]] $max_dbd_msgs = undef,
  Integer[1] $max_job_count = 10000,
  Integer[1] $max_step_count = 40000,
  Optional[Enum['no','yes']] $mem_limit_enforce = undef,
  Optional[Hash[Enum['WindowMsgs','WindowTime'],Integer[1]]] $msg_aggregation_params = undef,
  Optional[String] $plugin_dir = undef,
  Optional[String] $plug_stack_config = undef,
  Optional[Enum['power/cray','power/none']] $power_plugin = versioncmp($slurm::params::slurm_version, '24.11') >= 0 ? { true => undef, false => 'power/none'},
  Optional[Array[String]] $power_parameters = undef,
  String $preempt_type = 'preempt/none',
  Array[String] $preempt_mode = ['OFF'],
  Optional[Array[String]] $private_data = undef,
  Optional[String] $proctrack_type = undef,
  Integer[0,2] $propagate_prio_process = 0,
  Optional[Array[Enum['ALL','NONE','AS','CORE','CPU','DATA','FSIZE','MEMLOCK','NOFILE','NPROC','RSS','STACK']]] $propagate_resource_limits = undef,
  Optional[Array[Enum['ALL','NONE','AS','CORE','CPU','DATA','FSIZE','MEMLOCK','NOFILE','NPROC','RSS','STACK']]] $propagate_resource_limits_except = undef,
  Optional[String] $reboot_program = undef,
  Optional[Enum['KeepPartInfo','KeepPartState']] $reconfig_flags = undef,
  Optional[String] $resv_epilog = undef,
  Optional[String] $resv_prolog = undef,
  Integer[0,2] $return_to_service = 0,
  Optional[String] $salloc_default_command = undef,
  Optional[Hash[Enum['DestDir','Compression'],String]] $sbcast_parameters = undef,
  String $slurmctld_pid_file = '/var/run/slurmctld.pid',
  Optional[Array[String]] $slurmctld_plugstack = undef,
  String $slurmctld_port = "6817",
  String $slurmd_pid_file = '/var/run/slurmd.pid',
  Optional[Array[String]] $slurmd_plugstack = undef,
  String $slurmd_port = "6818",
  String $slurmd_spool_dir = '/var/spool/slurmd',
  String $slurm_user = 'root',
  String $slurmd_user = 'root',
  Optional[String] $srun_epilog = undef,
  Optional[String] $srun_prolog = undef,
  Optional[String] $srun_port_range = undef,
  String $state_save_location = '/var/spool/slurmctld',
  String $switch_type = 'switch/none',
  Array[String] $task_plugin = ['task/none'],
  Optional[Array[String]] $task_plugin_param = undef,
  Optional[String] $task_epilog = undef,
  Optional[String] $task_prolog = undef,
  Integer[1] $tcp_timeout = 2,
  String $tmp_fs = '/tmp',
  Enum['no','yes'] $track_wckey = 'no',
  Optional[String] $unkillable_step_program = undef,
  Optional[Array[String]] $auth_alt_type = undef,
  Optional[Array[String]] $auth_alt_parameters = undef,
  String $auth_type = 'auth/munge',
  Optional[String] $auth_info = undef,
  Enum['crypto/munge','crypto/openssl'] $crypto_type = 'crypto/munge',
  Optional[String] $job_credential_private_key = undef,
  Optional[String] $job_credential_public_certificate = undef,
  Enum['mcs/account','mcs/group','mcs/none','mcs/user'] $mcs_plugin = 'mcs/none',
  Optional[String] $mcs_parameters = undef,
  Integer[0,1] $use_pam = 0,
  String $munge_version = '0.5.11',
  Integer[0] $munge_gid = 951,
  Integer[0] $munge_uid = 951,
  String $munge_loc = '/etc/munge',
  String $munge_log_file = '/var/log/munge',
  String $munge_home_loc = '/var/lib/munge',
  String $munge_run_loc = '/run/munge',

  Integer[0] $batch_start_timeout = 10,
  Integer[0] $complete_wait = 0,
  Integer[0] $eio_timeout = 60,
  Integer[0] $epilog_msg_time = 2000,
  Integer[0] $get_env_timeout = 2,
  Integer[0] $group_update_time = 600,
  Integer[0] $inactive_limit = 0,
  Integer[0] $keep_alive_time = 0,
  Integer[0] $kill_wait = 30,
  Integer[0] $message_timeout = 10,
  Integer[2] $min_job_age = 300,
  Integer[0] $over_time_limit = 0,
  Integer[0] $prolog_epilog_timeout = 0,
  Integer[0] $resv_over_run = 0,
  Integer[0] $slurmctld_timeout = 120,
  Integer[0] $slurmd_timeout = 300,
  Integer[0] $unkillable_step_timeout = 60,
  Integer[0] $wait_time = 0,

  Optional[Integer[0]] $def_cpu_per_gpu = undef,
  Optional[Integer[0]] $def_mem_per_cpu = undef,
  Optional[Integer[0]] $def_mem_per_gpu = undef,
  Optional[Integer[0]] $def_mem_per_node = undef,
  Optional[String] $epilog = undef,
  Optional[String] $epilog_slurmctld = undef,
  Optional[Integer[0,2]] $fast_schedule = undef,
  Integer[0] $max_array_size = 1001,
  Optional[Integer[0]] $max_mem_per_cpu = undef,
  Optional[Integer[0]] $max_mem_per_node = undef,
  Integer[0] $max_tasks_per_node = 512,
  String $mpi_default = 'none',
  Optional[Hash[Enum['ports'],String]] $mpi_params = undef,
  Optional[String] $prolog_slurmctld = undef,
  Optional[String] $prolog = undef,
  Optional[Array[String]] $prolog_flags = undef,
  Optional[Array[String]] $x11_parameters = undef,
  Optional[String] $requeue_exit = undef,
  Optional[String] $requeue_exit_hold = undef,
  Integer[0] $scheduler_time_slice = 30,
  String $scheduler_type = 'sched/backfill',
  Optional[Array[String]] $scheduler_parameters = undef,
  String $select_type = 'select/linear',
  Optional[Array[String]] $select_type_parameters = undef,
  Integer[0] $vsize_factor = 0,

  String $priority_type = 'priority/basic',
  Optional[Array[String]] $priority_flags = undef,
  Integer[0] $priority_calc_period = 5,
  String $priority_decay_half_life = '7-0',
  Enum['NO','YES'] $priority_favor_small = 'NO',
  String $priority_max_age = '7-0',
  Enum['NONE','NOW','DAILY','WEEKLY','MONTHLY','QUARTERLY','YEARLY'] $priority_usage_reset_period = 'NONE',
  Integer[0] $priority_weight_age = 0,
  Integer[0] $priority_weight_fairshare = 0,
  Integer[0] $fair_share_dampening_factor = 1,
  Integer[0] $priority_weight_job_size = 0,
  Integer[0] $priority_weight_partition = 0,
  Integer[0] $priority_weight_qos = 0,
  Optional[Hash[String,Integer[0]]] $priority_weight_tres = undef,

  String $cluster_name,
  Optional[Array[String]] $communication_parameters = undef,
  Optional[String] $default_storage_host = undef,
  Optional[Integer[0]] $default_storage_port = undef,
  Optional[String] $default_storage_type = undef,
  Optional[String] $default_storage_user = undef,
  Optional[String] $default_storage_pass = undef,
  Optional[String] $default_storage_loc = undef,
  Optional[String] $accounting_storage_host = undef,
  Optional[String] $accounting_storage_backup_host = undef,
  Integer[0] $accounting_storage_port = 6819,
  Optional[String] $accounting_storage_enforce = undef,
  Optional[Array[String]] $accounting_storage_tres = undef,
  String $accounting_storage_type = 'accounting_storage/none',
  Optional[String] $accounting_storage_user = undef,
  Optional[String] $accounting_storage_pass = undef,
  Optional[String] $accounting_storage_loc = undef,
  Optional[Enum['NO','YES']] $accounting_store_jobhost = undef,
  Optional[Array[String]] $accounting_store_flags = undef,
  String $job_comp_type = 'jobcomp/none',
  Optional[String] $job_comp_host = undef,
  Integer[0] $job_comp_port = 6819,
  Optional[String] $job_comp_user = undef,
  Optional[String] $job_comp_pass = undef,
  Optional[String] $job_comp_loc = undef,
  String $job_acct_gather_type = 'jobacct_gather/none',
  Optional[Array[String]] $job_acct_gather_params = undef,
  Hash[Enum['task','energy','network','filesystem'],Integer[0]] $job_acct_gather_frequency = {'task' => 30,'energy' => 0,'network' => 0,'filesystem' => 0},
  Integer[0] $acct_gather_node_freq = 0,
  String $acct_gather_energy_type = 'acct_gather_energy/none',
  String $acct_gather_interconnect_type = 'acct_gather_interconnect/none',
  String $acct_gather_filesystem_type = 'acct_gather_filesystem/none',
  String $acct_gather_profile_type = 'acct_gather_profile/none',

  Optional[Array[String]] $debug_flags = undef,
  String $log_time_format = 'iso8601_ms',
  Enum['quiet','fatal','error','info','verbose','debug','debug2','debug3','debug4','debug5'] $slurmctld_debug = 'info',
  Enum['quiet','fatal','error','info','verbose','debug','debug2','debug3','debug4','debug5'] $slurmctld_syslog_debug = 'info',
  Optional[String] $slurmctld_log_file = undef,
  Enum['quiet','fatal','error','info','verbose','debug','debug2','debug3','debug4','debug5'] $slurmd_debug = 'info',
  Enum['quiet','fatal','error','info','verbose','debug','debug2','debug3','debug4','debug5'] $slurmd_syslog_debug = 'info',
  Optional[String] $slurmd_log_file = undef,
  Integer[0,1] $slurm_sched_log_level = 0,
  Optional[String] $slurm_sched_log_file = undef,

  Optional[String] $health_check_program = undef,
  Array[String] $health_check_node_state = ['ANY'],
  Integer[0] $health_check_interval = 0,

  Optional[String] $suspend_program = undef,
  Integer[0] $suspend_timeout = 30,
  Integer[0] $suspend_rate = 60,
  Integer[-1] $suspend_time = -1,
  Optional[String] $suspend_exc_nodes = undef,
  Optional[String] $suspend_exc_parts = undef,
  Optional[String] $resume_program = undef,
  Integer[0] $resume_timeout = 60,
  Integer[0] $resume_rate = 300,

  String $topology_plugin= 'topology/none',
  Array[String] $topology_param = ['NoCtldInAddrAny','NoInAddrAny'],
  String $route_plugin = 'route/default',
  Integer[1] $tree_width = 50,

  Array[Hash,1] $workernodes,
  Optional[Array[Hash,1]] $nodesets = undef,
  Array[Hash,1] $partitions,
  Optional[Array[Hash,1]] $gres_definitions = undef,

  Boolean $open_firewall = false,
  Array[String] $munge_packages = $slurm::params::munge_packages,
  Optional[String] $include_file = undef,
  Boolean $include_only = false,
) inherits slurm::params {

  # The following variables are version dependent
  if $slurmctld_syslog_debug != undef or $slurmd_syslog_debug != undef {
    if versioncmp('17.11', $slurm::params::slurm_version) > 0 {
      fail('Parameters SlurmctldSyslogDebug,SlurmdSyslogDebug are supported from version 17.11 onwards.')
    }
  }

  # Authentication service for SLURM if MUNGE is used as authentication plugin
  if  ($auth_type == 'auth/munge') or
      ($crypto_type == 'crypto/munge') {

    ensure_packages($munge_packages, {'ensure' => $munge_version})

    group{ 'munge':
      ensure => present,
      gid    => $munge_gid,
      system => true,
    }
    user{ 'munge':
      ensure  => present,
      comment => 'Munge',
      home    => '/var/lib/munge',
      gid     => $munge_gid,
      require => Group['munge'],
      system  => true,
      uid     => $munge_uid,
    }
    file{ dirtree($munge_loc, $munge_loc) :
      ensure  => directory,
    }
    -> file{ 'munge folder':
      ensure  => directory,
      path    => $munge_loc,
      owner   => 'munge',
      group   => 'munge',
      mode    => '1700',
      require => User['munge'],
    }
    file{ dirtree($munge_home_loc, $munge_home_loc) :
      ensure  => directory,
    }
    -> file{ 'munge homedir':
      ensure  => directory,
      path    => $munge_home_loc,
      owner   => 'munge',
      group   => 'munge',
      mode    => '1700',
      require => User['munge'],
    }
    file{ dirtree($munge_log_file, $munge_log_file) :
      ensure  => directory,
    }
    -> file{ 'munge log folder':
      ensure  => directory,
      path    => $munge_log_file,
      owner   => 'munge',
      group   => 'munge',
      mode    => '1700',
      require => User['munge'],
    }
    file{ dirtree($munge_run_loc, $munge_run_loc) :
      ensure  => directory,
    }
    -> file{ 'munge run folder':
      ensure  => directory,
      path    => $munge_run_loc,
      owner   => 'munge',
      group   => 'munge',
      mode    => '1755',
      require => User['munge'],
    }

    service{'munge':
      ensure    => running,
      enable    => true,
      hasstatus => true,
      subscribe => File['munge homedir','/etc/munge/munge.key'],
    }
  }

  # If openssl will be used for the crypto plugin, the key pair is a required file
  if $crypto_type == 'crypto/openssl' {
    $openssl_credential_files = [$job_credential_private_key,$job_credential_public_certificate]
  }
  else {
    $openssl_credential_files = []
  }

  # Check whether config files should be deployed or not
  #   if this is a 'head', 'db-head' or 'db' node always deploy.
  #   if this is a different node (i.e. 'worker', 'client'), optionally deploy config files
  if (   $slurm::node_type in ["head","db-head","db"]                                                      ) or 
     ( !($slurm::node_type in ["head","db-head","db"]) and !('enable_configless' in $slurmctld_parameters) ) {

    # Common SLURM configuration file
    file{'/etc/slurm/slurm.conf':
      ensure  => file,
      content => template('slurm/slurm.conf.erb'),
      owner   => 'slurm',
      group   => 'slurm',
      mode    => '0644',
      require => User['slurm'],
    }

    # Plugin loader
    file{ '/etc/slurm/plugstack.conf':
      ensure  => file,
      content => template('slurm/plugstack.conf.erb'),
      owner   => 'slurm',
      group   => 'slurm',
      mode    => '0644',
      require => User['slurm'],
    }

    # Accounting gatherer configuration file
    if  ('acct_gather_energy/ipmi' in $acct_gather_energy_type) or
        ('acct_gather_profile/hdf5' in $acct_gather_profile_type) or
        ('acct_gather_profile/influxdb' in $acct_gather_profile_type) or
        (['acct_gather_infiniband/ofed', 'acct_gather_interconnect/ofed'] in $acct_gather_interconnect_type) {
      class{ '::slurm::config::acct_gather':
        with_energy_ipmi       => ('acct_gather_energy/ipmi' in $acct_gather_energy_type),
        with_profile_hdf5      => ('acct_gather_profile/hdf5' in $acct_gather_profile_type),
        with_profile_influxdb  => ('acct_gather_profile/influxdb' in $acct_gather_profile_type),
        with_interconnect_ofed => (['acct_gather_infiniband/ofed', 'acct_gather_interconnect/ofed'] in $acct_gather_interconnect_type),
      }

      $acct_gather_conf_file = ['/etc/slurm/acct_gather.conf']
    }
    else {
      $acct_gather_conf_file = []
    }

    # Cgroup configuration file
    if  ('proctrack/cgroup' in $proctrack_type) or
        ('task/cgroup' in $task_plugin) or
        ('jobacct_gather/cgroup' in $job_acct_gather_type) {
      class{ '::slurm::config::cgroup':}

      $cgroup_conf_file = ['/etc/slurm/cgroup.conf']
    }
    else {
      $cgroup_conf_file = []
    }

    # GRES configuration file
    if  $gres_definitions {
      class{ '::slurm::config::gres':
        gres_definitions => $gres_definitions,
      }

      $gres_conf_file = ['/etc/slurm/gres.conf']
    }
    else {
      $gres_conf_file = []
    }

    # Topology plugin configuration file
    if  ('topology/tree' in $topology_plugin) {
      class{ '::slurm::config::topology':}
      $topology_conf_file = ['/etc/slurm/topology.conf']
    }
    else {
      $topology_conf_file = []
    }

    $common_config_files = [
      '/etc/slurm/plugstack.conf',
      '/etc/slurm/slurm.conf',
    ]

    $required_files = concat($openssl_credential_files, $acct_gather_conf_file, $cgroup_conf_file, $topology_conf_file, $gres_conf_file, $common_config_files)
  } else {

    file {
      '/etc/slurm/slurm.conf': ensure => absent;
      '/etc/slurm/plugstack.conf': ensure => absent;
      '/etc/slurm/acct_gather.conf': ensure => absent;
      '/etc/slurm/cgroup.conf': ensure => absent;
      '/etc/slurm/cgroup_allowed_devices_file.conf': ensure => absent;
      '/etc/slurm/gres.conf': ensure => absent;
      '/etc/slurm/topology.conf': ensure => absent;
    }
 
    $required_files = undef
  }

}
