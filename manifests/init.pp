# == Class: nrpe
#
# Full description of class nrpe here.
#
# === Parameters
#
# Document parameters here.
#
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# === Examples
#
#
# === Copyright
#
# Copyright 2013 Computer Action Team, unless otherwise noted.
#
class nrpe (
  Array[Stdlib::Ip::Address]    $allowed_hosts,
  Optional[Stdlib::Ip::Address] $server_address,
  Integer[1]                    $command_timeout,
  Stdlib::Absolutepath          $config,
  Stdlib::Absolutepath          $include_dir,
  Stdlib::Absolutepath          $libdir,
  Stdlib::Absolutepath          $sudo_path,
  Array[String]                 $packages,
  Boolean                       $manage_package,
  Boolean                       $purge,
  Boolean                       $recurse,
  String                        $service_name,
  Integer[0,1]                  $dont_blame_nrpe,
  String                        $log_facility,
  Stdlib::Port                  $server_port,
  Optional[String]              $command_prefix,
  Integer[0,1]                  $debug,
  Integer[1]                    $connection_timeout,
  Optional[Integer[0,1]]        $allow_bash_command_substitution,
  String                        $user,
  String                        $group,
  Stdlib::Absolutepath          $pid_file,
  Stdlib::Absolutepath          $ssl_dir,
  Optional[String]              $ssl_cert_file_content,
  Optional[String]              $ssl_privatekey_file_content,
  Optional[String]              $ssl_cacert_file_content,
  String                        $ssl_version,
  Array[String]                 $ssl_ciphers,
  Integer[0,2]                  $ssl_client_certs,
  Boolean                       $ssl_log_startup_params,
  Boolean                       $ssl_log_remote_ip,
  Boolean                       $ssl_log_protocol_version,
  Boolean                       $ssl_log_cipher,
  Boolean                       $ssl_log_client_cert,
  Boolean                       $ssl_log_client_cert_details,
  Optional[Hash]                $commands,
  Optional[Hash]                $plugins,
) {

  if $manage_package { ensure_packages($packages) }

  service { $service_name:
    ensure    => running,
    enable    => true,
    require   => Package[$packages],
    subscribe => File[$config],
  }

  file { $config:
    content => template('nrpe/nrpe.cfg.erb'),
    require => File['nrpe_include_dir'],
  }

  if $ssl_cert_file_content {
    file { $ssl_dir:
      ensure => directory,
      owner  => 'root',
      group  => $group,
      mode   => '0750',
    }
    file { "${ssl_dir}/ca-cert.pem":
      ensure  => file,
      owner   => 'root',
      group   => $group,
      mode    => '0640',
      content => $ssl_cacert_file_content,
      notify  => Service[$service_name],
    }
    file { "${ssl_dir}/nrpe-cert.pem":
      ensure  => file,
      owner   => 'root',
      group   => $group,
      mode    => '0640',
      content => $ssl_cert_file_content,
      notify  => Service[$service_name],
    }
    file { "${ssl_dir}/nrpe-key.pem":
      ensure  => file,
      owner   => 'root',
      group   => $group,
      mode    => '0640',
      content => $ssl_privatekey_file_content,
      notify  => Service[$service_name],
    }
  }

  file { 'nrpe_include_dir':
    ensure  => directory,
    name    => $include_dir,
    purge   => $purge,
    recurse => $recurse,
    require => Package[$packages],
  }
  if $commands { create_resources(nrpe::command, $commands) }
  if $plugins { create_resources(nrpe::plugin,  $plugins) }
}
