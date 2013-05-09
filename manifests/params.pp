class pe_caproxy::params
{
    $puppetmaster_conf   = '/etc/puppetlabs/httpd/conf.d/puppetmaster.conf'
    $certname            = $::clientcert
    $ca_master           = pick($::ca_server,$settings::ca_server)
    $non_ca_masters      = $::non_ca_servers
    $puppet_service_name = 'pe-httpd'
}
