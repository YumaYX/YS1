# frozen_string_literal: true

#
# Extends Hash to convert itself into a dynamic class.
#
class Hash
  #
  # Creates a dynamic class based on the hash.
  #
  # Each key becomes an attribute with getter and setter methods,
  # and each value is assigned during initialization.
  #
  # @return [Class]
  #   A dynamically created class with attributes derived from the hash.
  #
  # @example
  #   hash = { name: "Alice", age: 30 }
  #   klass = hash.to_dynamic_class
  #   obj = klass.new
  #   obj.name #=> "Alice"
  #   obj.age  #=> 30
  #
  def to_dynamic_class
    source = self

    Class.new do
      source.each_key { |key| attr_accessor key.to_sym }

      define_method(:initialize) do
        source.each do |key, value|
          instance_variable_set("@#{key}", value)
        end
      end
    end
  end
end
