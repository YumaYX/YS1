# frozen_string_literal: true

require "rake"

module YS1
  # Utility methods for file path handling
  module Path
    class << self
      # Builds a Rake::FileList from given inputs
      #
      # @param objs [Array<Object>] File paths, glob patterns, or nested arrays
      # @return [Rake::FileList] Combined file list
      #
      # @example
      #   YS1::Path.file_list("lib/**/*.rb", ["spec/**/*.rb"])
      #
      def file_list(*objs)
        Rake::FileList.new.tap { |fl| fl.include(objs) }.to_a
      end
    end
  end
end
