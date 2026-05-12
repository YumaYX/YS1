# frozen_string_literal: true

require "ipaddr"

require_relative "ip/cidr"

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
      # @see https://docs.ruby-lang.org/ja/latest/library/ipaddr.html
      def netmask(prefix)
        unless prefix.is_a?(Integer) && (0..32).include?(prefix)
          raise ArgumentError, "prefix must be an Integer between 0 and 32"
        end

        IPAddr.new("255.255.255.255").mask(prefix).to_s
      end
    end
  end
end
