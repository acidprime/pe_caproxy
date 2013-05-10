class pe_caproxy::master(
  $ca_master           = $pe_caproxy::params::ca_master,
  $cert_name           = $pe_caproxy::params::certname,
  $puppetmaster_conf   = $pe_caproxy::params::puppetmaster_conf,
  $puppet_service_name = $pe_caproxy::params::puppet_service_name,
) inherits pe_caproxy::params {

  if $::osfamily == 'Debian' {
    exec { 'a2enmod proxy':
      path    => '/usr/bin:/opt/puppet/sbin',
      creates => ['/etc/puppetlabs/httpd/mods-enabled/proxy.load',
        '/etc/puppetlabs/httpd/mods-enabled/proxy.conf'],
      notify  => Service[$puppet_service_name],
    }

    exec { 'a2enmod proxy_http':
      path    => '/usr/bin:/opt/puppet/sbin',
      creates => '/etc/puppetlabs/httpd/mods-enabled/proxy_http.load',
      notify  => Service[$puppet_service_name],
    }
  }

  # Template uses: @cert_name , @ca_master
  file { $puppetmaster_conf:
    ensure  => file,
    content => template("${module_name}/puppetmaster.conf.erb"),
    require => Augeas['puppet.conf ca_server'],
    notify  => Service[$puppet_service_name],
  }

  augeas{'puppet.conf ca' :
    context       => '/files//puppet.conf/master',
    changes       => "set ca false",
  }
  # Write this so settings::ca_server will work with
  # the agent -t on the local master's agent
  augeas{'puppet.conf ca_server' :
    context       => '/files//puppet.conf/agent',
    changes       => "set ca_server ${ca_master}",
  }
  augeas{'puppet.conf server' :
    context       => '/files//puppet.conf/agent',
    changes       => "set server ${ca_master}",
  }
  if ! defined(Service[$puppet_service_name]) {
    service { $puppet_service_name:
      ensure => running,
    }
  }

}
