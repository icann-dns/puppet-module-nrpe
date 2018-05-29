#
define nrpe::plugin (
  String                         $ensure  = 'present',
  Pattern[/\d{3,4}/]             $mode    = '0755',
  Optional[String]               $content = undef,
  Optional[String]               $source  = undef,
  Optional[Stdlib::Absolutepath] $libdir  = undef,
) {
  include nrpe
  $_libdir = $libdir ? {
    undef   => $nrpe::libdir,
    default => $libdir,
  }

  file { "${_libdir}/${title}":
    ensure  => $ensure,
    content => $content,
    source  => $source,
    owner   => 'root',
    group   => $nrpe::group,
    mode    => $mode,
    require => Package[$nrpe::packages],
  }
}
