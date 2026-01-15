# frozen_string_literal: true

# OpenClass Hash
class Hash
  #
  # Builds an anonymous class from the hash.
  #
  # Each hash key becomes an attribute with both reader and writer methods.
  # The corresponding values are assigned when an instance is initialized.
  #
  # @return [Class]
  #   An anonymous class with accessor methods for each hash key,
  #   pre-populated with the hash’s values.
  #
  # @example
  #   hash = { name: "Alice", age: 30 }
  #   klass = hash.to_anon_class
  #   obj = klass.new
  #   obj.name #=> "Alice"
  #   obj.age  #=> 30
  #
  def to_anon_class
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
