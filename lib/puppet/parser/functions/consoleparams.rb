module Puppet::Parser::Functions
  newfunction(:consoleparams, :type => :rvalue, :doc => <<-EOS
Returns Console/ENC parameters

Takes two arguments:
  1. certname, and
  2. external_node script that returns a yaml file

Returns an associative array (hash) with the parameters

Example:
  consoleparams($::certname,$settings::external_nodes) 
  which returns:
  {"custom_auth_conf"=>"false", "non_ca_servers"=>"master1.puppetlabs.vm,master2.puppetlabs.vm"}
    EOS
  ) do |arguments|

  require 'yaml'

  name = arguments[0]
  command = arguments[1]

  result = `#{command} #{node} 2>/dev/null`

  yamldata = YAML::load(result)
  return yamldata['parameters']
  end
end
