# frozen_string_literal: true

module YS1
  # Converts raw numeric values into human-readable strings.
  module Humanize
    # Binary size units (KiB = 1024 bytes).
    BYTE_UNITS = %w[B KiB MiB GiB TiB PiB EiB].freeze

    class << self
      # Formats a byte count using binary (IEC) units.
      #
      # @param value [Numeric] number of bytes (non-negative)
      # @param precision [Integer] decimal places for units above B
      # @return [String] human-readable size (e.g. "1.5 KiB")
      #
      # @raise [ArgumentError] if bytes is negative
      #
      # @example
      #   YS1::Humanize.bytes(0)
      #   # => "0 B"
      #
      #   YS1::Humanize.bytes(1536)
      #   # => "1.5 KiB"
      #
      #   YS1::Humanize.bytes(1024 * 1024 * 3)
      #   # => "3 MiB"
      def bytes(value, precision: 1)
        raise ArgumentError, "bytes must not be negative" if value.negative?

        n = value.to_f
        unit = 0
        while n >= 1024 && unit < BYTE_UNITS.length - 1
          n /= 1024
          unit += 1
        end

        formatted = unit.zero? ? n.to_i.to_s : format("%.#{precision}f", n)
        "#{formatted.sub(/\.0+$/, "")} #{BYTE_UNITS[unit]}"
      end

      # Formats a duration in seconds as "Xh Ym Zs".
      #
      # Zero seconds yields "0s". Days are folded into hours.
      #
      # @param seconds [Numeric] duration in seconds (non-negative)
      # @return [String] human-readable duration
      #
      # @raise [ArgumentError] if seconds is negative
      #
      # @example
      #   YS1::Humanize.duration(0)
      #   # => "0s"
      #
      #   YS1::Humanize.duration(3725)
      #   # => "1h 2m 5s"
      #
      #   YS1::Humanize.duration(45)
      #   # => "45s"
      def duration(seconds)
        raise ArgumentError, "seconds must not be negative" if seconds.negative?

        total = seconds.to_i
        return "0s" if total.zero?

        h, rem = total.divmod(3600)
        m, s = rem.divmod(60)

        parts = []
        parts << "#{h}h" if h.positive?
        parts << "#{m}m" if m.positive?
        parts << "#{s}s" if s.positive? || parts.empty?
        parts.join(" ")
      end

      # Formats an integer with thousands separators.
      #
      # @param value [Numeric] the number to format
      # @return [String] grouped digits (e.g. "1,234,567")
      #
      # @example
      #   YS1::Humanize.number(1_234_567)
      #   # => "1,234,567"
      #
      #   YS1::Humanize.number(-42)
      #   # => "-42"
      def number(value)
        sign = value.negative? ? "-" : ""
        digits = value.to_i.abs.to_s
        "#{sign}#{digits.reverse.scan(/\d{1,3}/).join(",").reverse}"
      end
    end
  end
end
