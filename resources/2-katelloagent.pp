class profiles::katelloagent(
  $activation_key    = undef,
  $ensure_registered = true,
  $katello_source    = 'satellite.example.com',
) {
  package { 'katello bootstrap':
    ensure   => present,
    provider => 'rpm',
    name     => "katello-ca-consumer-${katello_source}",
    source   => "http://${katello_source}/pub/katello-ca-consumer-latest.noarch.rpm",
  }

  if ($activation_key) {
    $_key = $activation_key
  } else {
    $_key = $facts['os']['name'] ? {
      'CentOS'  => $facts['os']['release']['major'] ? {
        '6'     => 'Generic CentOS 6 Server',
        '7'     => 'Generic CentOS 7 Server',
        default => fail("${::operatingsystem} ${::operatingsystemmajrelease} is not supported by this profile."),
      },
      'RedHat'  => $facts['os']['release']['major'] ? {
        '6'     => 'Generic RHEL 6 Server',
        '7'     => 'Generic RHEL 7 Server',
        default => fail("${::operatingsystem} ${::operatingsystemmajrelease} is not supported by this profile."),
      },
      default => fail("${::operatingsystem} is not supported by this profile."),
    }
  }

  if ($ensure_registered) {
    exec { 'register host':
      command => "subscription-manager register --org=\"Org_Name\" --activationkey=\"${$_key}\"",
      path    => '/usr/local/sbin:/usr/local/bin:/bin:/usr/sbin:/usr/bin',
      unless  => '/usr/sbin/subscription-manager status | grep Current || exit 1',
      require => Package['katello bootstrap'],
      before  => Package['katello-agent'],
    }
  } else {
    exec { 'unregister host':
      command => 'subscription-manager unregister',
      path    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin',
      unless  => '/usr/sbin/subscription-manager status | grep Unknown || exit 1',
      require => Package['katello bootstrap'],
      before  => Package['katello-agent'],
    }
  }

  package { 'katello-agent':
    ensure => present,
  }

  service { 'goferd':
    ensure  => running,
    enable  => true,
    require => Package['katello-agent'],
  }

  group { 'foreman-service':
      ensure => 'present',
  }

  user { 'foreman-service':
    ensure           => 'present',
    comment          => 'Foreman Remote Execution Service Account',
    forcelocal       => true,
    groups           => ['foreman-service'],
    home             => '/usr/share/foreman-service',
    managehome       => true,
    password         => '!!',
    password_max_age => '99999',
    password_min_age => '0',
    purge_ssh_keys   => true,
    shell            => '/bin/bash',
    require          => Group['foreman-service'],
  }

  ssh_authorized_key { 'foreman-proxy@satellite.example.com':
    ensure => present,
    user   => 'foreman-service',
    type   => 'ssh-rsa',
    # lint:ignore:140chars
    # lint:ignore:80chars
    key    => 'public_key_here',
    # lint:endignore
    # lint:endignore
  }
}
