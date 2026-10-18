# frozen_string_literal: true

module YS1
  # Saves and loads objects via Ruby serialization (Marshal).
  #
  # Useful for caching processed results between runs.
  module Report
    # Default file name used when none is given.
    DEFAULT_FILE = "obj.dat"

    class << self
      # Serializes the given object and writes it to a file.
      #
      # @param object [Object] the object to serialize
      # @param path [String] destination file path
      # @return [String] the path written (returns +path+ for convenience)
      #
      # @example
      #   YS1::Report.save({ count: 3 }, "stats.dat")
      #   # => "stats.dat"
      def save(object, path = DEFAULT_FILE)
        File.binwrite(path, Marshal.dump(object))
        path
      end

      # Reads a file and deserializes the object it contains.
      #
      # @param path [String] source file path
      # @return [Object] the deserialized object
      #
      # @raise [Errno::ENOENT] if the file does not exist
      #
      # @example
      #   YS1::Report.save({ count: 3 }, "stats.dat")
      #   YS1::Report.load("stats.dat")
      #   # => { count: 3 }
      def load(path = DEFAULT_FILE)
        Marshal.load(File.binread(path))
      end
    end
  end
end
