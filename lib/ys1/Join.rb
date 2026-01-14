# frozen_string_literal: true

module YS1
  # Join
  module Join
    # Perform a cross join (Cartesian product) on multiple arrays.
    #
    # This method accepts a variable number of arrays and yields each
    # combination one by one to the given block.
    # If no block is given, it returns an Enumerator.
    #
    # @param arrays [Array<Array>] one or more arrays to be cross-joined
    # @yieldparam values [Array] one combination of elements, in the same order as the input arrays
    # @yieldreturn [void]
    # @return [Enumerator, nil] Enumerator if no block is given, otherwise nil
    #
    # @example Using a block
    #   YS1::Join.cross(["A", "B"], ["1", "2"]) do |a, b|
    #     puts "#{a}#{b}"
    #   end
    #
    # @example Using as an Enumerator
    #   enum = YS1::Join.cross(["A", "B"], ["1", "2"])
    #   enum.map { |a, b| "#{a}-#{b}" }
    #
    def self.cross(*arrays)
      return enum_for(__method__, *arrays) unless block_given?

      recurse = lambda do |prefix, rest|
        if rest.empty?
          yield prefix
        else
          head, *tail = rest
          head.each do |item|
            recurse.call(prefix + [item], tail)
          end
        end
      end

      recurse.call([], arrays)
    end
  end
end