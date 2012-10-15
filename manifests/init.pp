# Class: uwsgi
#
# Install uwsgi.
#
# Parameters:
# * $uwsgi_user. Defaults to 'www-data'.
#
# Templates:
#   - uwsgi.erb => /etc/init.d/uwsgi
#
class uwsgi {

  $uwsgi_conf = '/etc/uwsgi/'
  $uwsgi_logdir = '/var/log/uwsgi/'
  $uwsgi_log = '/var/log/uwsgi/emperor.log'

  # XXX - we could turn the upstart service script into an erb template, and
  # actually use these values
  $real_uwsgi_user = $::uwsgi_user ? {
    undef   => 'www-data',
    default => $::uwsgi_user
  }

  if ! defined(Package['uwsgi']) {
    package { 'uwsgi':
      ensure => installed,
      provider => pip,
    }
  }

  #restart-command is a quick-fix here, until http://projects.puppetlabs.com/issues/1014 is solved
  # XXX - currently disabled, no restart in the upstart service script
  service { 'uwsgi':
    provider   => upstart,
    ensure     => running,
    enable     => true,
    require    => File['/etc/init/uwsgi.conf']
  }

  file { $uwsgi_conf:
    ensure  => directory,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    require => Package['uwsgi'],
  }

  file { '/etc/init/uwsgi.conf':
    ensure  => file,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    require => Package['uwsgi'],
    source => "puppet:///modules/uwsgi/etc/init/uwsgi.conf"
  }

  file { $uwsgi_logdir:
    ensure  => directory,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    require => Package['uwsgi'],
  }

  file { $uwsgi_log:
    ensure  => file,
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
    #require => [ Package['uwsgi'], File[$uwsgi_logdir] ],
    require => Package['uwsgi'],
  }


}
