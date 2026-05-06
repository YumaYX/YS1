# frozen_string_literal: true

module YS1
  module Ollama
    # Ollama Options
    #
    # Provides a flexible container for building Ollama API options.
    # Allows dynamic addition of option keys and automatically defines
    # getter/setter methods for each key.
    class Options
      # @return [Hash<Symbol, Object>] internal options storage
      attr_reader :options

      # Initializes a new Options instance
      #
      # @return [void]
      def initialize
        @options = {}
      end

      # Adds or updates an option key-value pair
      #
      # Dynamically defines accessor methods for the given key
      # unless they already exist.
      #
      # @param key [String, Symbol] option key
      # @param value [Object] option value
      # @return [Options] returns self for method chaining
      #
      # @example Add options
      #   opts.add(:temperature, 0.7)
      #   opts.add("top_p", 0.9)
      #
      # @example Chain calls
      #   opts.add(:temperature, 0.7)
      #       .add(:top_p, 0.9)
      def add(key, value)
        key = key.to_sym
        define_accessor(key) unless respond_to?("#{key}=")
        @options[key] = value
        self
      end

      # Returns options as a hash
      #
      # @return [Hash<Symbol, Object>] options hash
      def to_h
        @options
      end

      private

      # Dynamically defines getter and setter methods for a key
      #
      # @param key [Symbol] option key
      # @return [void]
      #
      # @example Generated methods
      #   opts.temperature = 0.7
      #   opts.temperature #=> 0.7
      def define_accessor(key)
        define_singleton_method("#{key}=") do |v|
          @options[key] = v
        end

        define_singleton_method(key) do
          @options[key]
        end
      end
    end
  end
end
