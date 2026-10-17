# frozen_string_literal: true

module YS1
  # Utility methods for file path handling
  module Path
    class << self
      # Expands the given inputs into a flat array of matching file paths.
      #
      # Each input may be a path, a shell-style glob pattern, or a nested array
      # of them. Patterns are expanded with {Dir.glob}; a literal path that does
      # not exist expands to nothing.
      #
      # @param objs [Array<String, Array>] paths, glob patterns, or nested arrays
      # @return [Array<String>] expanded file paths
      #
      # @example
      #   YS1::Path.file_list("lib/ys1/*.rb", ["exe/*"])
      #   # => ["lib/ys1/csv.rb", "lib/ys1/ip.rb", ..., "exe/ys1", ...]
      #
      # @example Nested arrays
      #   YS1::Path.file_list("a.rb", ["b.rb", ["c.txt"]])
      #   # => ["a.rb", "b.rb", "c.txt"]
      def file_list(*objs)
        objs.flatten.flat_map { |obj| Dir.glob(obj.to_s) }
      end
    end
  end
end
