# slurm/workernode/setup.pp
#
# Creates folders/logfiles and installs packages specific to workernode
#
# @param slurmd_spool_dir Fully qualified pathname of a directory into which the Slurm deamon, slurmd, saves its state
# @param slurmd_log_file Fully qualified pathname of a file into which the slurmd daemon's logs are written
# @param packages Packages to install
#
# version 20170829
#
# Copyright (c) CERN, 2016-2017
# Authors: - Philippe Ganz <phganz@cern.ch>
#          - Carolina Lindqvist <calindqv@cern.ch>
#          - Pablo Llopis <pablo.llopis@cern.ch>
# License: GNU GPL v3 or later.
#

class slurm::client::configless (
Optional[String] $controllers = undef 
) inherits slurm::params {

  include ::slurm::config
  
  ensure_packages($slurm::params::configless_client_packages, {'ensure' => $slurm::params::slurm_version})
  $sackd_conf = '/etc/default/sackd'
  $sackd_override_dir = '/etc/systemd/system/sackd.service.d'
  $sackd_override = "${sackd_override_dir}/munge_requirement.conf"
  file { $sackd_conf: 
    content =>  "SACKD_OPTIONS='--conf-server ${controllers}'"
  }

  service { 'sackd':
    ensure    => running,
    enable    => true,
    subscribe => File[$sackd_conf],
    require   => [File[$sackd_conf], Package[$slurm::params::configless_client_packages], Service['munge']]
  }
  if  ($slurm::config::auth_type == 'auth/munge') or
  ($slurm::config::crypto_type == 'crypto/munge') {
    file {
      $sackd_override_dir:
        ensure  => directory;
      $sackd_override:
        ensure  => file,
        mode    => '0644',
        content => '[Unit]
After=munge.service
Wants=munge.service
',
        before => Service['sackd'],
        notify => Service['sackd']
    }
    }
}
  
