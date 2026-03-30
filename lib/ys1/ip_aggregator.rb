# frozen_string_literal: true

require "ipaddr"
require_relative "ip"

module YS1
  # Provides functionality to aggregate IPv4 addresses into CIDR blocks.
  module IPAggregator
    # Represents a CIDR block
    # @attr [String] addr The network address (e.g., "10.0.0.0")
    # @attr [Integer] prefix The CIDR prefix length (e.g., 24)
    Cidr = Struct.new(:addr, :prefix)

    class << self
      # Convert an IPv4 string into a 32-bit integer
      #
      # @param ip [String] IPv4 address (e.g., "192.168.1.1")
      # @return [Integer] 32-bit integer representation
      def ip_to_u32(ip)
        IPAddr.new(ip).to_i
      end

      # Convert a 32-bit integer into an IPv4 string
      #
      # @param number [Integer] 32-bit integer
      # @return [String] IPv4 address string
      def u32_to_ip(number)
        IPAddr.new(number, Socket::AF_INET).to_s
      end

      # Check if a block of integers represents a continuous sequence
      #
      # @param block [Array<Integer>] List of IPs as integers
      # @return [Boolean] True if all elements are sequential
      def continuous?(block)
        block.each_cons(2).all? { |a, b| b == a + 1 }
      end

      # Check if a block is aligned to its size
      #
      # @param start [Integer] Starting IP (as integer)
      # @param size [Integer] Block size
      # @return [Boolean] True if start is divisible by size
      def aligned?(start, size)
        (start % size).zero?
      end

      # Normalize and aggregate IPv4 addresses into CIDR blocks
      #
      # @param ip_list [Array<String>] List of IPv4 address strings
      # @return [Array<Cidr>] Aggregated CIDR blocks
      def aggregate_ips(ip_list)
        ints = normalize(ip_list)

        result = []
        i = 0

        while i < ints.length
          size = find_block_size(ints, i)
          result << build_cidr(ints[i], size)
          i += size
        end

        result
      end

      # Convert IP strings into sorted, unique 32-bit integers
      #
      # @param ip_list [Array<String>] List of IPv4 address strings
      # @return [Array<Integer>] Sorted unique integer representations
      def normalize(ip_list)
        ip_list.map { |ip| ip_to_u32(ip) }.sort.uniq
      end

      # Determine the largest valid CIDR block size starting at a given index
      #
      # @param ints [Array<Integer>] Sorted IPs as integers
      # @param index [Integer] Starting index
      # @return [Integer] Block size (power of 2)
      def find_block_size(ints, index)
        size = 1

        loop do
          next_size = size * 2
          break if index + next_size > ints.length

          block = ints[index, next_size]

          break unless continuous?(block)
          break unless aligned?(block[0], next_size)

          size = next_size
        end

        size
      end

      # Build a CIDR object from a starting IP and block size
      #
      # @param start [Integer] Starting IP as integer
      # @param size [Integer] Block size
      # @return [Cidr] CIDR representation
      def build_cidr(start, size)
        prefix = 32 - Math.log2(size).to_i
        mask = prefix.zero? ? 0 : ((~0 << (32 - prefix)) & 0xffffffff)
        network = start & mask

        Cidr.new(u32_to_ip(network), prefix)
      end

      # Convert CIDR blocks into ACL format
      #
      # @param raw [Array<Cidr>] List of CIDR objects
      # @return [Array<String>] ACL-formatted
      def cidrs_to_acl(raw)
        raw.map do |c|
          if c.prefix.eql?(32)
            "host #{c.addr}"
          else
            "#{c.addr} #{YS1::IP.netmask(c.prefix)}"
          end
        end
      end
    end
  end
end

# CLI entry point
#
# Reads IP addresses from a file and prints aggregated CIDR blocks.
if __FILE__ == $PROGRAM_NAME
  # @type [String] Input filename (default: ips.txt)
  file_name = ARGV.size >= 1 ? ARGV.first : "ips.txt"

  # @type [Array<String>] List of IPs from file
  ips = File.read(file_name).lines.map(&:chomp).reject(&:empty?)

  # @type [Array<YS1::IPAggregator::Cidr>] Aggregated CIDRs
  raw = YS1::IPAggregator.aggregate_ips(ips)

  # Output result
  puts YS1::IPAggregator.cidrs_to_acl(raw)
end
