# frozen_string_literal: true

require "ipaddr"

module YS1
  module IP
    # Cidr represents an IP address and its network prefix in CIDR notation (e.g., 192.168.1.0/24).
    class Cidr
      # Initializes a new Cidr object.
      # @param addr [String] The IP address string (e.g., "192.168.1.0").
      # @param prefix [Integer] The prefix length (must be between 0 and 32).
      def initialize(addr, prefix)
        @ip = IPAddr.new(addr)
        raise ArgumentError unless prefix.between?(0, 32)

        @prefix = prefix
      end

      # Returns the IP address string part of the CIDR block.
      # @return [String] The IP address string.
      def addr = @ip.to_s
      attr_reader :prefix

      # Converts the CIDR object into its standard string representation (e.g., "192.168.1.0/24").
      # @return [String] The CIDR block string.
      def to_s = "#{addr}/#{prefix}"
    end
  end
end
