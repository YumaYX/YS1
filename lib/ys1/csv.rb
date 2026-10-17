# frozen_string_literal: true

require "csv"
require "json"

# YS1::CSV handles reading and processing CSV files.
module YS1
  # YS1::CSV provides functionality to read data from a CSV file
  # and convert it into structured formats like an array of hashes (via #read)
  # or JSON (via #to_json).
  #
  # It also includes {Enumerable} over the rows, so iteration helpers such as
  # `map`, `select`, `each_with_index`, and `to_a` work directly on the object.
  class CSV
    include Enumerable

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

    # Iterates over each CSV row, reading the file on first access.
    #
    # @yieldparam row [Hash] a single row as a hash of headers to values
    # @return [Enumerator, self] an Enumerator when no block is given
    #
    # @example
    #   csv = YS1::CSV.new("data.csv")
    #   csv.each { |row| p row }
    #   csv.map { |row| row["Header1"] }
    def each(&block)
      return to_enum(:each) unless block

      (@data || read).each(&block)
      self
    end

    # Generates a JSON string representation of the CSV data.
    # If data has not been read yet, #read is called first.
    # @return [String] A JSON formatted string of the CSV data.
    def to_json(*_args)
      JSON.generate(@data || read)
    end
  end
end
