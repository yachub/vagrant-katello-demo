# Provide a class to manage yum-cron
class profiles::autoupdates (
  Boolean          $enabled             = true,
  Integer[0]       $random_sleep        = 60,
  Integer[2, 4]    $debug_level         = 2,
  Enum['stdio', 'email', 'None'] $output = 'email',
  String           $email_to            = 'updates@example.com',
  String           $apply_updates       = 'yes',
  String           $el6_check_first     = 'yes',
) {

  if $enabled {
    $ensure_autoupdates = present
  } else {
    $ensure_autoupdates = absent
  }

  package { 'yum-cron':
    ensure => $ensure_autoupdates
  }

  case $facts['os']['release']['major'] {
    '6': {
      file { '/etc/sysconfig/yum-cron':
        ensure  => $ensure_autoupdates,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => epp('profiles/yum-cron-el6.epp', {
          'el6_check_first' => $el6_check_first,
          'email_to'        => $email_to,
        }),
        require => Package['yum-cron']
      }

      # Remove exits if lockfile does not exist
      #if [ ! -f /var/lock/subsys/yum-cron ]; then
      #  exit 0
      #fi
      file { '/etc/cron.d/0yum.cron':
        ensure  => $ensure_autoupdates,
        owner   => 'root',
        group   => 'root',
        mode    => '0744',
        source  => 'puppet:///modules/profiles/0yum.cron',
        require => Package['yum-cron']
      }

      # Replace default file
      file { '/etc/cron.daily/0yum.cron':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0744',
        content => '# This file is managed by Puppet and has moved to /etc/cron.d/0yum.cron',
        require => File['/etc/cron.d/0yum.cron'],
      }
    }

    '7': {
      file { '/etc/yum/yum-cron-puppet.conf':
        ensure  => $ensure_autoupdates,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => epp('profiles/yum-cron.conf.epp', {
          'random_sleep'  => $random_sleep,
          'debug_level'   => $debug_level,
          'output'        => $output,
          'email_to'      => $email_to,
          'apply_updates' => $apply_updates,
        }),
        require => Package['yum-cron']
      }
    }

    default: { fail("EL ${::operatingsystemmajrelease} is not supported by this profile.")}
  }

  # When the yum-cron service is enabled it triggers default
  # yum-hourly and yum-daily jobs to run.
  # This implementation does not use yum-daily or yum-hourly.
  service { 'yum-cron':
    ensure  => stopped,
    require => Package['yum-cron']
  }
}
