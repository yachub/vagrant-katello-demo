# vagrant-katello-demo

This repo serves as a demo environment for a [Foreman](https://theforeman.org)
and [Katello](https://www.theforeman.org/plugins/katello/) plugin installation.

It leverages [Forklift](https://github.com/theforeman/forklift) to build the
Foreman installation and automatically creates a small set of lifecycle
environments, repositories, products, content views, and activation keys.
Additionally, it configures the environment for remote execution.

The installation currently targets Foreman 1.20 and Katello 3.10 in order to
closely mirror a Red Hat Satellite installation, as version 6.5.2 currently
targets these upstream versions.

## Requirements
* [Vagrant](https://www.vagrantup.com/docs/) and
[VirtualBox](https://www.virtualbox.org) installed
* System with:
  * CPU: 4 cores (vagrant box uses 2)
  * Memory: 16GB (vagrant box uses 8)
  * 5GB disk space

## Usage
* Simply clone this repo and run `vagrant up`
* The process will take about 25 - 30 minutes to complete (May widley vary due
to internet connection speed)
* Once complete, navigate to https://localhost:8443, and login with default 
credentials "admin" and "changeme"

## Getting Started
* The [Foreman](https://www.theforeman.org/manuals/nightly/index.html)
and [Katello](https://theforeman.org/plugins/katello/nightly/user_guide/)
manuals have some great information, however I would highly recommend starting
with the [Planning for Red Hat Satellite 6 Guide](https://access.redhat.com/documentation/en-us/red_hat_satellite/6.5/html/planning_for_red_hat_satellite_6/index),
which will help you get started with the architecture and deployment.
  * When Satellite refers to "Capsules", those are what Foreman calls "Smart Proxies".
* There are also many other useful installation and administration guides
[here](https://access.redhat.com/documentation/en-us/red_hat_satellite).

## Scripts and Puppet Resources
* Once the content views and life cycle environments are setup to your
satisfaction, then if desired take a look at some scripts used to help automate
some of the daily maintaining located in the resources directory of this repo.
  *  `1-katello-environmentLifecycle.sh`: This script is designed specifically
  for a bi-weekly patching process (Assuming the use of only a Development and 
  Production life cycle environments). For every odd week throughout the year
  this publishes a new version of every content view on Monday and emails out a
  list of packages that will be promoted up the environment. Then on Tuesday
  the latest packages are promoted up the environment. The same process is
  repeated on even weeks for the Production environment.
  * `2-katelloagent.pp`: This is a Puppet profile that is used to register a
  host with Foreman using an activation key and setup a service account with
  ssh key for the remote execution feature.
  * `3-global.yaml`: This is a Puppet hiera file using a Sudo Puppet module to
  grant appropriate sudo access for the service account created above.
  * `4-autoupdates.pp`: This is a Puppet profile used to setup yum-cron for
  auto patching in the next step (disables the yum-cron service).
  * `5-katello-autoReboot.sh`: This script creates remote execution jobs to
  execute yum-cron and optionally perform a reboot based on the Host Collection
  that a host is a member of. Again this performs the auto updating and
  rebooting on a bi-weekly basis (Dev on odd weeks and prod on even weeks).
  * `6-katello-hostCollectionReport.sh`: This is a script used to audit your
  host collections and email out a weekly report of all hosts and what host
  collection they are a member of.