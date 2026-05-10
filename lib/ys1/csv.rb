# frozen_string_literal: true

require "csv"
require "json"

# YS1::CSV handles reading and processing CSV files.
module YS1
  # YS1::CSV provides functionality to read data from a CSV file
  # and convert it into structured formats like an array of hashes (via #read)
  # or JSON (via #to_json).
  class CSV
    # @return [String] The path to the CSV file.
    attr_reader :file_path
    # @return [Array<Hash>, nil] The loaded CSV data.
    attr_reader :data

    # @param file_path [String] The path to the CSV file.
    def initialize(file_path)
      @file_path = file_path
    end

    # Reads the CSV file at @file_path.
    # The data is read with BOM|UTF-8 encoding, headers are treated as keys,
    # and the result is mapped to an array of hashes.
    # @return [Array<Hash>] An array of hashes representing the CSV rows.
    def read
      @data = ::CSV
              .read(
                @file_path,
                encoding: "BOM|UTF-8",
                headers: true
              )
              .map(&:to_h)
    end

    # Generates a JSON string representation of the CSV data.
    # If data has not been read yet, #read is called first.
    # @return [String] A JSON formatted string of the CSV data.
    def to_json(*_args)
      @data ||= read
      JSON.generate(@data)
    end
  end
end
