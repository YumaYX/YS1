# frozen_string_literal: true

require "csv"
require "json"

# Ys1
module Ys1
  # A module for converting CSV data to various formats.
  module CsvConverter
    class << self
      # Converts CSV data to a hash, using the first column as keys.
      #
      # @param csv_file_name [String] The name of the CSV file.
      # @return [Hash] The CSV data converted to a hash.
      def csv_to_hash(csv_file_name, &block)
        csv_data = if RUBY_VERSION >= "3.0"
                     CSV.read(csv_file_name, encoding: "BOM|UTF-8", headers: true)
                   else
                     CSV.read(csv_file_name, "r:BOM|UTF-8", headers: true)
                   end
        csv_to_hash_core(csv_data, &block)
      end

      # Converts CSV data to a hash, using the first column as keys.
      #
      # @param csv_data [CSV::Table] The CSV data.
      # @return [Hash] The CSV data converted to a hash.
      def csv_to_hash_core(csv_data)
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
      def csv_to_array(csv_file_name)
        if RUBY_VERSION >= "3.0"
          CSV.read(csv_file_name, encoding: "BOM|UTF-8", headers: true).map(&:to_h)
        else
          CSV.read(csv_file_name, "r:BOM|UTF-8", headers: true).map(&:to_h)
        end
      end

      # Generates a JSON file from a CSV file.
      #
      # @param filename [String] The name of the CSV file.
      # @param format [Symbol] The format to convert to (:hash or :array).
      # @return [void]
      def generate_json_file(filename, format = :array)
        output = filename.gsub(/\.csv$/, ".json")
        data = Ys1::CsvConverter.send("csv_to_#{format}", filename)
        File.write(output, JSON.dump(data))
      end
    end
  end
end
