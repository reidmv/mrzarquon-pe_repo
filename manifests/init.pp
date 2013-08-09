# == Class: pe_repo
#
# Full description of class pe_repo here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if it
#   has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should not be used in preference to class parameters  as of
#   Puppet 2.6.)
#
# === Examples
#
#  class { pe_repo:
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ]
#  }
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2013 Your name here, unless otherwise noted.
#
class pe_repo (
  $puppet_master = $::fqdn,
  $repo_versions = 'el-6-x86_64',
  $package_mirror = $::fqdn,
){
  
  File {
    ensure => file,
    mode   => 644,
    owner  => root,
    group  => root,
  }

  #build file structure
  file { '/opt/pe_repo': ensure => directory, }
  file { '/opt/pe_repo/html': ensure => directory, }

  file { '/opt/pe_repo/html/index.html':
    content => template('pe_repo/index.erb'),
  }
  file { '/opt/pe_repo/html/deb.bash':
    content => template('pe_repo/deb.bash.erb'),
  }
  file { '/opt/pe_repo/html/el.bash':
    content => template('pe_repo/el.bash.erb'),
  }
  file { '/opt/pe_repo/html/puppet.conf':
    content => template('pe_repo/puppet.conf.erb'),
  }
  file { '/opt/pe_repo/html/el.repo':
    content => template('pe_repo/elrepo.erb'),
  }
  file { '/opt/pe_repo/html/pe_version':
    content => "{$pe_version}",
  }
  file { '/opt/pe_repo/html/GPG-KEY-puppetlabs':
    source => "puppet:///modules/pe_repo/GPG-KEY-puppetlabs",
  }

  #enable port 80 and sharing the repo
  file { '/etc/puppetlabs/httpd/conf.d/pe_repo.conf':
    source => 'puppet:///modules/pe_repo/pe_repo.conf',
    notify => Service['pe-httpd'],
  }

  #everyone gets windows because its easy and not stupid
  exec { 'download_windows':
    command => "/usr/bin/curl -O http://s3.amazonaws.com/pe-builds/released/${pe_version}/puppet-enterprise-${pe_version}.msi",
    cwd     => '/opt/pe_repo/html/',
    creates => "/opt/pe_repo/html/puppet-enterprise-${pe_version}.msi",
    require => File['/opt/pe_repo/html'],
  }

  #eventually this should be something fancy with create_resources and an array that you pass it of all the repos you want built
  pe_repo::repo {$repo_versions:}
  pe_repo::repo {'ubuntu-12.04-i386':}
}
