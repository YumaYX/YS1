# frozen_string_literal: true

module YS1
  # Renders arrays of rows as aligned plain-text tables.
  #
  # Accepts an array of hashes (as produced by {YS1::CSV#read}) or an
  # array of arrays.
  module Table
    class << self
      # Formats rows into an aligned pipe-delimited table string.
      #
      # When +rows+ is an array of hashes the header row is taken from the
      # keys of the first hash (or from +headers+ when given). When +rows+
      # is an array of arrays, +headers+ may be supplied to add a header row.
      #
      # @param rows [Array<Hash>, Array<Array>] the rows to render
      # @param headers [Array<String>, nil] optional explicit header row
      # @return [String] the rendered table (no trailing newline)
      #
      # @raise [ArgumentError] if rows is empty and no headers are given
      #
      # @example Array of hashes
      #   rows = [
      #     { "id" => "1", "name" => "Alice" },
      #     { "id" => "2", "name" => "Bob" }
      #   ]
      #   puts YS1::Table.format(rows)
      #   # id | name
      #   # --+-----
      #   # 1  | Alice
      #   # 2  | Bob
      #
      # @example Array of arrays with headers
      #   YS1::Table.format([[1, "a"], [2, "bb"]], headers: %w[n x])
      #   # n | x
      #   # -+--
      #   # 1 | a
      #   # 2 | bb
      def format(rows, headers: nil)
        raise ArgumentError, "rows must not be empty" if rows.empty? && headers.nil?

        matrix, header = build_matrix(rows, headers)
        widths = column_widths(matrix)
        render(matrix, widths, header)
      end

      private

      # Builds a matrix of string cells.
      #
      # @param rows [Array<Hash>, Array<Array>]
      # @param headers [Array<String>, nil]
      # @return [Array(Array<Array<String>>, Boolean)]
      #   the cell matrix and whether the first row is a header
      def build_matrix(rows, headers)
        return [[headers.map(&:to_s)], true] if rows.empty?
        return hash_matrix(rows, headers) if rows.first.is_a?(Hash)

        array_matrix(rows, headers)
      end

      # Builds the matrix for an array of hashes.
      #
      # @param rows [Array<Hash>]
      # @param headers [Array<String>, nil]
      # @return [Array(Array<Array<String>>, Boolean)]
      def hash_matrix(rows, headers)
        keys = headers || rows.first.keys
        body = rows.map { |row| keys.map { |key| row[key].to_s } }
        [[keys.map(&:to_s), *body], true]
      end

      # Builds the matrix for an array of arrays.
      #
      # @param rows [Array<Array>]
      # @param headers [Array<String>, nil]
      # @return [Array(Array<Array<String>>, Boolean)]
      def array_matrix(rows, headers)
        body = rows.map { |row| row.map(&:to_s) }
        return [[headers.map(&:to_s), *body], true] if headers

        [body, false]
      end

      # Computes the maximum display width of each column.
      #
      # @param matrix [Array<Array<String>>]
      # @return [Array<Integer>]
      def column_widths(matrix)
        return [] if matrix.empty?

        matrix.transpose.map { |col| col.map(&:size).max }
      end

      # Renders the matrix with padding and an optional separator row.
      #
      # @param matrix [Array<Array<String>>]
      # @param widths [Array<Integer>]
      # @param header [Boolean] whether the first row is a header
      # @return [String]
      def render(matrix, widths, header)
        return "" if matrix.empty?

        lines = matrix.map { |row| join_row(row, widths) }
        lines.insert(1, widths.map { |w| "-" * w }.join("+")) if header
        lines.map(&:rstrip).join("\n")
      end

      # Joins one row of cells with padding.
      #
      # @param cells [Array<String>]
      # @param widths [Array<Integer>]
      # @return [String]
      def join_row(cells, widths)
        cells.each_with_index
             .map { |cell, i| cell.ljust(widths[i]) }
             .join(" | ")
      end
    end
  end
end
