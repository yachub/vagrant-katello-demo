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
