# Define: uwsgi::app
#
# Install a uwsgi app in /etc/uwsgi/apps-available (and symlink in /etc/uwsgi/apps-enabled).
#
#
# Parameters :
# * ensure: typically set to "present" or "absent". Defaults to "present"
# * content: app definition (should be a template).
# * listen : address/port the server listen to. Defaults to 80. Auto enable ssl if 443
# * access_log : custom acces logs. Defaults to /var/log/uwsgi/$name_access.log
#
# XXX - this is based off puppet-nginx and is completed untested / uncessary at present - XXX
# this task (installing an app) is handled by each app's fabric deployment scripts
##
define uwsgi::app(
  $ensure='present',
  $content='',
  $ensure              = 'present',
  $listen              = '80',
  $access_log          = undef) {

  case $ensure {
    'present' : {
      uwsgi::install_app { $name:
        content => $content
      }
    }
    'absent' : {
      exec { "/bin/rm -f /etc/uwsgi/apps-enabled/${name}":
        onlyif  => "/bin/sh -c '[ -L /etc/uwsgi/apps-enabled/${name} ] && \
          [ /etc/uwsgi/apps-enabled/$name -ef /etc/uwsgi/apps-available/${name} ]'",
        notify  => Service['uwsgi'],
        require => Package['uwsgi'],
      }
    }
    default: { err ("Unknown ensure value: '$ensure'") }
  }

  $real_access_log = $access_log ? {
    undef   => "/var/log/uwsgi/${name}_access.log",
    default => $access_log,
  }

 }
