# frozen_string_literal: true

module YS1
  module Ollama
    # Ollama Options
    class Options
      attr_reader :options

      def initialize
        @options = {}
      end

      def add(key, value)
        key = key.to_sym
        define_accessor(key) unless respond_to?("#{key}=")
        @options[key] = value
        self
      end

      def to_h
        @options
      end

      private

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
