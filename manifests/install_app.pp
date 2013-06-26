# Define: install_app
#
# Install uwsgi application
# This definition is private, not intended to be called directly
#
define uwsgi::install_app($content=undef) {
  include uwsgi

  # first, make sure the app config exists
  case $content {
    undef: {
      file { "/etc/uwsgi/apps-available/${name}":
        ensure  => present,
        mode    => '0644',
        owner   => 'root',
        group   => 'root',
        alias   => "apps-${name}",
        notify  => Service['uwsgi'],
        require => Package['uwsgi'],
      }
    }
    default: {
      file { "/etc/uwsgi/apps-available/${name}":
        ensure  => present,
        mode    => '0644',
        owner   => 'root',
        group   => 'root',
        alias   => "apps-$name",
        content => $content,
        require => Package['uwsgi'],
        notify  => Service['uwsgi'],
      }
    }
  }

  # now, enable it.
  exec { "ln -s /etc/uwsgi/apps-available/${name} /etc/uwsgi/apps-enabled/${name}":
    unless  => "/bin/sh -c '[ -L /etc/uwsgi/apps-enabled/${name} ] && \
      [ /etc/uwsgi/apps-enabled/${name} -ef /etc/uwsgi/apps-available/${name} ]'",
    path    => ['/usr/bin/', '/bin/'],
    notify  => Service['uwsgi'],
    require => [File["/etc/uwsgi/apps-available/${name}"], Package['uwsgi']],
  }
}
