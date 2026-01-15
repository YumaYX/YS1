# frozen_string_literal: true

module YS1
  # Join utilities
  module Join
    # Generate the Cartesian product of multiple arrays.
    #
    # @param arrays [Array<Array>] arrays to be joined
    # @yieldparam combo [Array] one combination of elements
    # @return [Enumerator] when no block is given
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
    # @example No arguments
    #   YS1::Join.cross.to_a
    #   # => [[]]
    def self.cross(*arrays, &)
      return enum_for(__method__, *arrays) unless block_given?

      if arrays.empty?
        yield []
        return
      end

      arrays
        .reduce([[]]) do |acc, arr|
          acc.product(arr).map { |prefix, item| prefix + [item] }
        end
        .each(&)
    end

    # Read files and generate the Cartesian product of their lines.
    #
    # Each file is read as an array of lines (newline removed),
    # then passed to {#cross}.
    #
    # @param filenames [Array<String>] file paths
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
    def self.cross_from_files(*filenames, &)
      arrays = filenames.map do |filename|
        File.readlines(filename, chomp: true)
      end

      cross(*arrays, &)
    end
  end
end
