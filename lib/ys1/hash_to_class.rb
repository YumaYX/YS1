# frozen_string_literal: true

module YS1
  # The `HashToClass` module provides functionality to convert a hash into a dynamic class.
  module HashToClass
    class << self
      # Creates a dynamic class based on the given hash.
      #
      # This method defines a class with attributes corresponding to the keys in the hash.
      # Each key in the hash will be converted to an attribute with getter and setter methods.
      #
      # @param hash [Hash] The hash used to create the class.
      # @return [Class] The dynamically created class with the attributes from the hash.
      def create_dynamic_class(hash)
        # Define the class dynamically
        Class.new do
          # Define an attribute for each key in the hash
          # @param key [Symbol] The key of the hash which will be converted to an attribute.
          hash.each_key { |key| attr_accessor key.to_sym }

          # Initialize the dynamic class with values from the hash
          #
          # @param none
          # @return [void]
          define_method(:initialize) do
            # Set instance variables for each key-value pair in the hash
            # @param key [Symbol] The key of the hash.
            # @param value [Object] The value associated with the key.
            hash.each { |key, value| instance_variable_set("@#{key}", value) }
          end
        end
      end
    end
  end
end
