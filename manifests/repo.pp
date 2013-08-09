define pe_repo::repo (
  $installer_build = $title,
){
  # right now this only stages the installers for the current version of the master
  # this should get updated with better logic to allow staging of multiple different
  # versions of the pe installer in an environment.
  
  staging::file { "puppet-enterprise-${pe_version}-${installer_build}.tar.gz":
    source => "https://s3.amazonaws.com/pe-builds/released/${pe_version}/puppet-enterprise-${pe_version}-${installer_build}.tar.gz",
  }
  staging::extract { "puppet-enterprise-${pe_version}-${installer_build}.tar.gz":
    target  => '/opt/pe_repo/html',
    creates => "/opt/pe_repo/html/puppet-enterprise-${pe_version}-${installer_build}",
    require => [
      Staging::File["puppet-enterprise-${pe_version}-${installer_build}.tar.gz"],
      File['/opt/pe_repo/html']
    ]
  }
  #our nice symlink to make the .repo files happy
  file { "/opt/pe_repo/html/${installer_build}":
    ensure  => link,
    target  => "/opt/pe_repo/html/puppet-enterprise-${pe_version}-${installer_build}/packages/${installer_build}",
    require => Staging::Extract["puppet-enterprise-${pe_version}-${installer_build}.tar.gz"],
  }
}
