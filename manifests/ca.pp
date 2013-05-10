class pe_caproxy::ca (
  $non_ca_masters   = $pe_caproxy::params::non_ca_masters,
  $ca_master        = $pe_caproxy::params::ca_master,
  $managepuppetconf = $pe_caproxy::params::managepuppetconf,
) inherits pe_caproxy::params {
  $masters_normalized = regsubst($non_ca_masters,'\s', '', G)
  $masters_list       = split($masters_normalized, ',')
  $fact_save_allowed  = stradd($masters_list, $ca_master)

  validate_bool($managepuppetconf)
  
  class { 'auth_conf::defaults':
    master_certname => $::fact_puppetmaster_certname,
  }
  if $managepuppetconf {
    augeas {'puppet.conf ca_server' :
      context => '/files//puppet.conf/main',
      changes => "set ca_server ${::clientcert}",
    }
  }
  # This emulates what request_manager would do:
  auth_conf::acl { '/certificate_status':
    auth       => 'yes',
    acl_method => ['find','search', 'save', 'destroy'],
    allow      => 'pe-internal-dashboard',
    order      => 085,
  }
  auth_conf::acl { '/certificate_revocation_list':
    auth       => 'any',
    acl_method => ['find'],
    allow      => '*',
    order      => 085,
  }
  Auth_conf::Acl <| title == 'save-/facts'|> {
    path       => '/facts',
    auth       => 'yes',
    acl_method => 'save',
    allow      => $fact_save_allowed,
    order      => 095,
    require    => Augeas['puppet.conf ca_server'],
  }
  exec { 'node:parameters':
    path        => '/opt/puppet/bin:/bin',
    cwd         => '/opt/puppet/share/puppet-dashboard',
    environment => 'RAILS_ENV=production',
    command     => "rake node:parameters name=${::clientcert} parameters=custom_auth_conf=false",
    #  refreshonly => true,
  }
}
