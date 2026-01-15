# frozen_string_literal: true

require "ipaddr"

module YS1
  # IP
  module IP
    class << self
      #
      # Convert a CIDR prefix length to an IPv4 netmask string.
      #
      # @param prefix [Integer]
      #   CIDR prefix length (0–32)
      #
      # @return [String]
      #   IPv4 netmask (e.g. "255.255.255.0")
      #
      # @raise [ArgumentError]
      #   If prefix is not an Integer between 0 and 32
      #
      # @example
      #   YS1::IP.netmask(24)
      #   # => "255.255.255.0"
      #
      #   YS1::IP.netmask(32)
      #   # => "255.255.255.255"
      #
      #   YS1::IP.netmask(0)
      #   # => "0.0.0.0"
      #
      # @see IPAddr#mask
      def netmask(prefix)
        unless prefix.is_a?(Integer) && (0..32).include?(prefix)
          raise ArgumentError, "prefix must be an Integer between 0 and 32"
        end

        IPAddr.new("255.255.255.255").mask(prefix).to_s
      end
    end
  end
end

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
