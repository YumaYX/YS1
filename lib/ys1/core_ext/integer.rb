# frozen_string_literal: true

# OpenClass Integer
class Integer
  #
  # Convert an integer (0–32) representing a CIDR prefix length
  # into its corresponding IPv4 netmask string.
  #
  # @return [String] IPv4 netmask (e.g. "255.255.255.0")
  # @raise [ArgumentError] if the integer is not between 0 and 32
  # @example
  #   24.ipv4mask  # => "255.255.255.0"
  #   32.ipv4mask  # => "255.255.255.255"
  #   0.ipv4mask   # => "0.0.0.0"
  def ipv4mask
    YS1::IP.netmask(self)
  end
end
