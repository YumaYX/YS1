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
        @options[key] = value
        self
      end

      def to_h
        @options
      end
    end
  end
end
