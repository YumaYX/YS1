# frozen_string_literal: true

require 'csv'
require 'json'

module YS1
  class CSV
    attr_reader :file_path
    attr_reader :data
def initialize(file_path)
      @file_path = file_path
    end

    def read
      @data = ::CSV
        .read(
          @file_path,
          encoding: "BOM|UTF-8",
          headers: true
          )
        .map(&:to_h)
    end

    def to_json
      @data ||= self.read
      JSON.generate(@data)
    end
  end
end

