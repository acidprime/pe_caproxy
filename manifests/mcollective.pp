class pe_caproxy::mcolletive (
  $stomp_server_value = $pe_caproxy::params::stomp_server_value
) inherits pe_caproxy::params {
  $params = consoleparams($::clientcert, $settings::external_nodes)

  if !has_key($params, 'fact_stomp_server') {
    exec { 'node:parameters':
      path        => '/opt/puppet/bin:/bin',
      cwd         => '/opt/puppet/share/puppet-dashboard',
      environment => 'RAILS_ENV=production',
      command     => "rake node:parameters name=${::clientcert} parameters=fact_stomp_server=$stomp_server_value",
    }
  }
}
