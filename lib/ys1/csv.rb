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

    class << self
      # Writes rows to a CSV file.
      #
      # @param file_path [String] destination file path
      # @param rows [Array<Hash>, Array<Array>] rows to write
      # @param headers [Array<String>, nil] header order; defaults to the
      #   keys of the first hash (or none for arrays)
      # @return [void]
      #
      # @example Array of hashes
      #   YS1::CSV.write("out.csv", [{ "id" => "1", "name" => "Alice" }])
      #
      # @example Array of arrays
      #   YS1::CSV.write("out.csv", [%w[1 Alice]], headers: %w[id name])
      def write(file_path, rows, headers: nil)
        return if rows.empty? && headers.nil?

        ::CSV.open(file_path, "w") do |csv|
          if rows.first.is_a?(Hash)
            write_hashes(csv, rows, headers)
          else
            write_arrays(csv, rows, headers)
          end
        end

        nil
      end

      private

      # Writes an array of hashes, using the given headers or the first
      # hash's keys.
      #
      # @param csv [::CSV] open CSV writer
      # @param rows [Array<Hash>] rows to write
      # @param headers [Array<String>, nil] column order
      # @return [void]
      def write_hashes(csv, rows, headers)
        keys = (headers || rows.first.keys).map(&:to_s)
        csv << keys
        rows.each { |row| csv << keys.map { |key| row[key] } }
      end

      # Writes an array of arrays, optionally preceded by a header row.
      #
      # @param csv [::CSV] open CSV writer
      # @param rows [Array<Array>] rows to write
      # @param headers [Array<String>, nil] header row
      # @return [void]
      def write_arrays(csv, rows, headers)
        csv << headers if headers
        rows.each { |row| csv << row }
      end
    end

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

    # Returns rows restricted to the given columns.
    #
    # @param names [Array<String>] the column names to keep
    # @return [Array<Hash>] rows containing only the selected columns
    #
    # @example
    #   csv = YS1::CSV.new("data.csv")
    #   csv.select_columns("id", "name")
    #   # => [{ "id" => "1", "name" => "Alice" }, ...]
    def select_columns(*names)
      keys = names.flatten.map(&:to_s)

      (@data || read).map { |row| row.slice(*keys) }
    end

    # Casts column values using the given converters.
    #
    # Unknown columns are ignored. Values are passed through the converter
    # proc, which may raise (e.g. `Integer()` on a non-numeric value).
    #
    # @param mapping [Hash{String, Symbol => #call}] column name to converter
    # @return [self]
    #
    # @example
    #   csv = YS1::CSV.new("data.csv")
    #   csv.cast("id" => ->(v) { Integer(v) })
    #   csv.map { |row| row["id"] }
    #   # => [1, 2, 3]
    def cast(mapping)
      @data ||= read
      @data.each do |row|
        mapping.each do |column, converter|
          key = column.to_s
          row[key] = converter.call(row[key]) if row.key?(key)
        end
      end
      self
    end

    # Renders the rows as an aligned text table.
    #
    # @return [String] the table produced by {YS1::Table.format}
    #
    # @example
    #   puts YS1::CSV.new("data.csv").to_table
    def to_table
      require_relative "table"

      YS1::Table.format(@data || read)
    end
  end
end
