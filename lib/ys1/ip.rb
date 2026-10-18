# frozen_string_literal: true

require "ipaddr"

require_relative "ip/cidr"

module YS1
  # IP
  module IP
    # Non-globally-routable ranges used by {.private?}: IPv4 RFC1918,
    # loopback, and link-local, plus IPv6 unique-local, loopback and
    # link-local.
    PRIVATE_RANGES = [
      IPAddr.new("10.0.0.0/8"),
      IPAddr.new("172.16.0.0/12"),
      IPAddr.new("192.168.0.0/16"),
      IPAddr.new("127.0.0.0/8"),
      IPAddr.new("169.254.0.0/16"),
      IPAddr.new("fc00::/7"),
      IPAddr.new("::1"),
      IPAddr.new("fe80::/10")
    ].freeze

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

      # Checks whether an IP address falls inside a CIDR block or range.
      #
      # @param range [String, YS1::IP::Cidr] a CIDR block (e.g. "10.0.0.0/24"),
      #   a plain address, or a {YS1::IP::Cidr}
      # @param ip [String] the IP address to test
      # @return [Boolean] true if +ip+ is inside +range+
      #
      # @raise [IPAddr::InvalidAddressError] if either argument is not a valid IP
      #
      # @example
      #   YS1::IP.include?("10.0.0.0/24", "10.0.0.5")
      #   # => true
      #
      #   YS1::IP.include?("10.0.0.0/24", "10.0.1.5")
      #   # => false
      def include?(range, ip)
        IPAddr.new(range.to_s).include?(IPAddr.new(ip))
      end

      # Checks whether an IP address is private, loopback, or link-local.
      #
      # IPv4 uses the RFC1918, loopback (127/8), and link-local (169.254/16)
      # ranges. IPv6 uses unique-local (fc00::/7), loopback (::1), and
      # link-local (fe80::/10).
      #
      # @param ip [String] the IP address to test
      # @return [Boolean] true if the address is non-global
      #
      # @example
      #   YS1::IP.private?("192.168.1.1")
      #   # => true
      #
      #   YS1::IP.private?("8.8.8.8")
      #   # => false
      def private?(ip)
        addr = IPAddr.new(ip)

        PRIVATE_RANGES.any? { |range| range.include?(addr) }
      end

      # Returns the IP version of an address.
      #
      # @param ip [String] the IP address to inspect
      # @return [Integer] 4 or 6
      #
      # @example
      #   YS1::IP.version("192.168.1.1")
      #   # => 4
      #
      #   YS1::IP.version("::1")
      #   # => 6
      def version(ip)
        IPAddr.new(ip).ipv4? ? 4 : 6
      end
    end
  end
end
