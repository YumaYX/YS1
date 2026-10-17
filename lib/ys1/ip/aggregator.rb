# frozen_string_literal: true

require "ipaddr"
require_relative "../ip"

module YS1
  module IP
    # Provides functionality to aggregate IPv4 addresses into CIDR blocks.
    #
    # Only {.aggregate_ips}, {.cidrs_to_acl} and the integer/string
    # conversions are public; the block-detection helpers are implementation
    # details.
    module Aggregator
      class << self
        # Convert an IPv4 string into a 32-bit integer
        #
        # @param ip [String] IPv4 address (e.g., "192.168.1.1")
        # @return [Integer] 32-bit integer representation
        #
        # @example
        #   YS1::IP::Aggregator.ip_to_u32("0.0.0.1")
        #   # => 1
        def ip_to_u32(ip)
          IPAddr.new(ip).to_i
        end

        # Convert a 32-bit integer into an IPv4 string
        #
        # @param number [Integer] 32-bit integer
        # @return [String] IPv4 address string
        #
        # @example
        #   YS1::IP::Aggregator.u32_to_ip(1)
        #   # => "0.0.0.1"
        def u32_to_ip(number)
          IPAddr.new(number, Socket::AF_INET).to_s
        end

        # Normalize and aggregate IPv4 addresses into CIDR blocks
        #
        # @param ip_list [Array<String>] List of IPv4 address strings
        # @return [Array<Cidr>] Aggregated CIDR blocks
        #
        # @example
        #   YS1::IP::Aggregator.aggregate_ips(%w[10.0.0.2 10.0.0.3]).map(&:to_s)
        #   # => ["10.0.0.2/31"]
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

        # Convert CIDR blocks into ACL format
        #
        # @param raw [Array<Cidr>] List of CIDR objects
        # @return [Array<String>] ACL-formatted
        #
        # @example
        #   cidrs = [YS1::IP::Cidr.new("10.0.0.1", 32)]
        #   YS1::IP::Aggregator.cidrs_to_acl(cidrs)
        #   # => ["host 10.0.0.1"]
        def cidrs_to_acl(raw)
          raw.map do |c|
            if c.prefix.eql?(32)
              "host #{c.addr}"
            else
              "#{c.addr} #{YS1::IP.netmask(c.prefix)}"
            end
          end
        end

        private

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
            block = ints[index, next_size]
            break if (index + next_size > ints.length) || !continuous?(block) || !aligned?(block[0], next_size)

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

          YS1::IP::Cidr.new(u32_to_ip(network), prefix)
        end
      end
    end
  end
end
