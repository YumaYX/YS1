# frozen_string_literal: true

module YS1
  # Join utilities
  module Join
    class << self
      #
      # Generate the Cartesian product of multiple arrays.
      #
      # @param arrays [Array<Array>] arrays to be joined
      # @param limit [Integer, nil] maximum number of combinations to emit
      # @yieldparam combo [Array] one combination of elements
      # @return [Enumerator] when no block is given
      #
      # @raise [ArgumentError] if limit is negative
      #
      # @example Basic usage
      #   YS1::Join.cross([1, 2], [:a, :b]).to_a
      #   # => [[1, :a], [1, :b], [2, :a], [2, :b]]
      #
      # @example With a block
      #   YS1::Join.cross([1, 2], [:a, :b]) do |combo|
      #     p combo
      #   end
      #
      # @example With a limit
      #   YS1::Join.cross([1, 2], [:a, :b], limit: 2).to_a
      #   # => [[1, :a], [1, :b]]
      #
      # @example No arguments
      #   YS1::Join.cross.to_a
      #   # => [[]]
      def cross(*arrays, limit: nil, &block)
        raise ArgumentError, "limit must not be negative" if limit&.negative?
        return enum_for(__method__, *arrays, limit: limit) unless block_given?

        combos = arrays.reduce([[]]) do |acc, arr|
          acc.product(arr).map { |prefix, item| prefix + [item] }
        end

        count = 0
        combos.each do |combo|
          break if limit && count >= limit

          yield combo
          count += 1
        end
      end

      #
      # Read files and generate the Cartesian product of their lines.
      #
      # Each file is read as an array of lines (newline removed),
      # then passed to {.cross}.
      #
      # @param filenames [Array<String>] file paths
      # @param limit [Integer, nil] maximum number of combinations to emit
      # @yieldparam combo [Array<String>] one combination of lines
      # @return [Enumerator] when no block is given
      #
      # @example Files
      #   # a.txt
      #   # 1
      #   # 2
      #
      #   # b.txt
      #   # a
      #   # b
      #
      #   YS1::Join.cross_from_files("a.txt", "b.txt").to_a
      #   # => [["1", "a"], ["1", "b"], ["2", "a"], ["2", "b"]]
      def cross_from_files(*filenames, limit: nil, &block)
        arrays = filenames.map do |filename|
          File.readlines(filename, chomp: true)
        end

        cross(*arrays, limit: limit, &block)
      end
    end
  end
end
