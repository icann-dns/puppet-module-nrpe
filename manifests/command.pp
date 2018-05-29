#
define nrpe::command (
  String                         $command,
  String                         $ensure      = 'present',
  Boolean                        $sudo        = false,
  String                         $sudo_user   = 'root',
  Optional[Stdlib::Absolutepath] $include_dir = undef,
  Optional[Stdlib::Absolutepath] $libdir      = undef,
) {
  include nrpe
  $_include_dir = $include_dir ? {
    undef   => $nrpe::include_dir,
    default => $include_dir,
  }
  $_libdir = $libdir ? {
    undef   => $nrpe::libdir,
    default => $libdir,
  }
  $sudo_path = $nrpe::sudo_path

  file { "${_include_dir}/${title}.cfg":
    ensure  => $ensure,
    content => template('nrpe/command.cfg.erb'),
    owner   => 'root',
    group   => $nrpe::group,
    mode    => '0644',
    require => Package[$nrpe::packages],
    notify  => Service[$nrpe::service_name],
  }

}
