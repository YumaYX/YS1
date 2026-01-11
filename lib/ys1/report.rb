# frozen_string_literal: true

module YS1
  # Report module provides methods to save and load objects using serialization.
  module Report
    class << self
      #
      # Serializes the given object and saves it to a file.
      #
      # @param object [Object] The object to be serialized and saved.
      # @param output_name [String] The name of the file where the object will be saved. Default is "obj.dat".
      #
      # @return [nil]
      def save(object, output_name = "obj.dat")
        serialized = Marshal.dump(object)
        File.binwrite(output_name, serialized)
      end

      #
      # Loads a serialized object from a file.
      #
      # @param input_name [String] The name of the file from which the object will be loaded. Default is "obj.dat".
      #
      # @return [Object] The deserialized object.
      def load(input_name = "obj.dat")
        data = File.read(input_name)
        Marshal.load(data)
      end
    end
  end
end
