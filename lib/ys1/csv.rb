# frozen_string_literal: true

require "csv"
require "json"

# YS1
module YS1
  # A module for converting CSV data to various formats.
  module Csv
    class << self
      # Converts CSV data to a hash, using the first column as keys.
      #
      # @param csv_file_name [String] The name of the CSV file.
      # @return [Hash] The CSV data converted to a hash.
      def to_hash(csv_file_name)
        csv_data = YS1::Csv.read(csv_file_name)
        hash = {}
        csv_data.each do |row|
          header_key = row.headers.first
          key = row[header_key]
          hash[key] = (block_given? ? yield(row) : row.to_h)
        end
        hash
      end

      # Converts CSV data to an array of hashes.
      #
      # @param csv_file_name [String] The name of the CSV file.
      # @return [Array<Hash>] The CSV data converted to an array of hashes.
      def to_array(csv_file_name)
        YS1::Csv.read(csv_file_name).map(&:to_h)
      end

      # Reads a CSV file and returns its content as a CSV::Table object.
      #
      # @param csv_file_name [String] The path to the CSV file.
      # @return [CSV::Table] The content of the CSV file as a CSV::Table object.
      def read(csv_file_name)
        CSV.read(csv_file_name, encoding: "BOM|UTF-8", headers: true)
      end

      # Generates a JSON file from a CSV file.
      #
      # @param filename [String] The name of the CSV file.
      # @param format [Symbol] The format to convert to (:hash or :array).
      # @return [String] JSON file name
      def generate_json_file(filename, format = :array)
        output = filename.gsub(/\.csv$/, ".json")
        data = YS1::Csv.send("to_#{format}", filename)
        File.write(output, JSON.dump(data))
        output
      end

      ##
      # Converts an array of hashes into a CSV-formatted string.
      #
      # Each hash in the array represents a row, and the union of all keys across hashes
      # becomes the header row. Missing values are output as blank cells.
      #
      # @param array_of_hashes [Array<Hash>] the data to be converted into CSV
      # @return [String] a CSV string with headers
      #
      # @example
      #   hashes_to_csv([{name: "Alice", age: 30}, {name: "Bob", age: 25}])
      #   # => "name,age\nAlice,30\nBob,25\n"
      #
      def hashes_to_csv(array_of_hashes)
        headers = array_of_hashes.map(&:keys).flatten.uniq
        CSV.generate(headers: true) do |csv|
          csv << headers
          array_of_hashes.each do |hash|
            row = headers.map { |key| hash[key] }
            csv << row
          end
        end
      end
    end
  end
end
