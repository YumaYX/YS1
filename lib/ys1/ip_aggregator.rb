# frozen_string_literal: true

require "ipaddr"

module YS1
  # IPAggregator
  module IPAggregator
    class << self
      # Summarize sequential IPv4 addresses into CIDR blocks.
      #
      # @param ip_list [Array<String>] list of IPv4 address strings
      # @param min_mask [Integer] minimum allowed mask length (smaller = larger networks)
      # @return [Array<Array(String,Integer)>] array of [ip, mask] pairs
      def summarize_ips(ip_list, min_mask: 0)
        ips = ip_list.uniq.sort.map { IPAddr.new(_1) }.sort_by(&:to_i)

        ips.chunk_while { |a, b| b.to_i == a.to_i + 1 }
           .flat_map { |c| range_to_cidrs(c.first, c.last, min_mask: min_mask) }
      end

      # Convert CIDR entries into ACL formatted strings.
      #
      # @param entries [Array<Array(String,Integer)>] array of [ip, mask] pairs
      # @return [Array<String>] ACL formatted lines
      def cidrs_to_acl(entries)
        entries.map { |e| cidr_to_acl(e) }
      end

      private

      def mask_to_netmask(mask)
        [(0xffffffff << (32 - mask)) & 0xffffffff]
          .pack("N").unpack("C4").join(".")
      end

      def cidr_to_acl(entry)
        ip, mask = entry
        return "host #{ip}" if mask == 32

        "#{ip} #{mask_to_netmask(mask)}"
      end

      def largest_block(start_ip, end_ip, min_mask)
        mask = 32
        best = [start_ip.to_s, 32]

        while mask >= min_mask
          block = IPAddr.new("#{start_ip}/#{mask}")

          break unless block.to_range.first == start_ip
          break if block.to_range.last > end_ip

          best = [start_ip.to_s, mask]
          mask -= 1
        end

        best
      end

      def range_to_cidrs(start_ip, end_ip, min_mask:)
        res = []
        cur = start_ip

        while cur <= end_ip
          ip_str, mask = largest_block(cur, end_ip, min_mask)
          res << [ip_str, mask]
          block = IPAddr.new("#{cur}/#{mask}")
          cur = IPAddr.new(block.to_range.last.to_i + 1, Socket::AF_INET)
        end

        res
      end
    end
  end
end
