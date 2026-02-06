# frozen_string_literal: true

require "ipaddr"

module YS1
  # IPAggregator
  module IPAggregator
    class << self
      # Summarize a list of IPv4 addresses into aggregated CIDR blocks.
      #
      # @param ip_list [Array<String>] list of IPv4 address strings (e.g. "192.168.0.1")
      # @return [Array<Array(String,Integer)>] array of [ip, mask] CIDR entries
      #
      # @example
      #   summarize_ips(["192.168.0.1","192.168.0.2"])
      #   #=> [["192.168.0.1", 32], ["192.168.0.2", 32]]
      def summarize_ips(ip_list)
        ints = ip_list.map { ip_to_i(_1) }.uniq.sort
        build_ranges(ints).flat_map { |start_ip, end_ip| range_to_cidrs(start_ip, end_ip) }
      end

      # Convert CIDR entries into ACL formatted strings.
      #
      # @param entries [Array<Array(String,Integer)>] array of [ip, mask] pairs
      # @return [Array<String>] ACL formatted lines
      def cidrs_to_acl(entries)
        entries.map { |e| cidr_to_acl(e) }
      end

      private

      # rubocop:disable Metrics/MethodLength
      def build_ranges(ints)
        ranges = []
        return ranges if ints.empty?

        s = p = ints[0]
        ints[1..]&.each do |n|
          if n == p + 1
            p = n
          else
            (ranges << [s, p]
             s = p = n)
          end
        end
        ranges << [s, p]
      end
      # rubocop:enable Metrics/MethodLength

      def range_to_cidrs(start_ip, end_ip)
        res = []
        cur = start_ip
        while cur <= end_ip
          align = cur & -cur
          remain = end_ip - cur + 1
          block = [align, 1 << Math.log2(remain).floor].min
          res << [i_to_ip(cur), 32 - Math.log2(block).to_i]
          cur += block
        end
        res
      end

      def ip_to_i(ip)
        ip.split(".").inject(0) { |a, o| (a << 8) + o.to_i }
      end

      def i_to_ip(int)
        [24, 16, 8, 0].map { |b| (int >> b) & 255 }.join(".")
      end

      def mask_to_netmask(mask)
        [(0xffffffff << (32 - mask)) & 0xffffffff]
          .pack("N").unpack("C4").join(".")
      end

      def cidr_to_acl((ip, mask))
        mask == 32 ? "host #{ip}" : "#{ip} #{mask_to_netmask(mask)}"
      end
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  file_name = ARGV.size >= 1 ? ARGV.first : "ips.txt"
  ips = File.read(file_name).lines.map(&:chomp).reject(&:empty?)
  raw = YS1::IPAggregator.summarize_ips(ips)
  puts YS1::IPAggregator.cidrs_to_acl(raw)
end
