# frozen_string_literal: true

# YS1 module containing the JTable class
module YS1
  # Represents a table with columns and data.
  # Allows data manipulation and operations like cross-joins.
  class JTable
    # @return [Hash] The data stored in the table, where keys are column names
    #   and values are arrays of data for each column.
    attr_reader :data

    # Initializes a new JTable with specified columns.
    #
    # @param columns [Array<String, Symbol>] The list of column names for the table.
    def initialize(columns)
      @data = {}
      columns.map { |column| @data[column.to_sym] ||= [] }
    end

    # Performs a cross join on the table data, returning all possible combinations
    # of row values from each column.
    #
    # @return [Array<Array>] An array of arrays, where each inner array is a combination
    #   of values from different columns.
    def cross_join
      first = array.first
      first.product(*@data.values[1..])
    end

    # Adds data to a specified column in the table.
    #
    # @param column [String, Symbol] The name of the column to which data should be added.
    # @param data [Object] The data to add to the specified column.
    # @return [void]
    def add_data(column, data)
      @data[column.to_sym] << data
    end

    class << self
      # Reads data from a CSV file and converts it into a hash of JTables.
      #
      # @param csv_file_name [String] The name of the CSV file to read.
      # @return [Hash{String => YS1::JTable}] A hash where keys are unique identifiers
      #   from the CSV and values are JTable instances representing the data.
      def table_2_data(csv_file_name)
        csv = YS1::Csv.read(csv_file_name)
        data_columns = csv.headers.to_a[1..] # Skip the first header
        all_data = Hash.new { |hash, key| hash[key] = YS1::JTable.new(data_columns) }

        csv.each do |line|
          current = line.first.last || current
          next unless current

          line.to_a[1..].each { |col, val| all_data[current].add_data(col, val) if val }
        end
        all_data
      end
    end
  end
end
