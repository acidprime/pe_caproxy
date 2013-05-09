module Puppet::Parser::Functions
  newfunction(:stradd, :type => :rvalue, :doc => <<-EOS
Appends string to end of an array

*Example:*

    stradd(['1','2','3'],'4')

Would result in:

  ['1','2','3','4']
    EOS
  ) do |arguments|

    # Check that 2 arguments have been given ...
    raise(Puppet::ParseError, "stradd(): Wrong number of arguments " +
      "given (#{arguments.size} for 2)") if arguments.size != 2

    a = arguments[0]
    b = arguments[1]

    # Check that both args are arrays.
    unless a.is_a?(Array) and b.is_a?(String)
      raise(Puppet::ParseError, 'stradd(): Requires an array and a string to work with')
    end

    result = a << b

    return result
  end
end
