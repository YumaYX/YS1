# frozen_string_literal: true

module YS1
  # Minimal line-based diff built on a longest-common-subsequence table.
  #
  # Suited to small texts such as configuration snippets or CSV dumps.
  module Diff
    class << self
      # Compares two texts line by line.
      #
      # @param old [String, Array<String>] the original text (or lines)
      # @param new [String, Array<String>] the new text (or lines)
      # @return [Array<Array(String, String)>] ops as [op, line] pairs
      #   where op is "=", "-", or "+"
      #
      # @example
      #   YS1::Diff.lines("a\nb\nc", "a\nx\nc")
      #   # => [["=", "a"], ["-", "b"], ["+", "x"], ["=", "c"]]
      def lines(old, new)
        old_lines = to_lines(old)
        new_lines = to_lines(new)
        table = lcs_table(old_lines, new_lines)
        backtrack(table, old_lines, new_lines)
      end

      # Renders a unified-diff-style string for two texts.
      #
      # @param old [String, Array<String>] the original text (or lines)
      # @param new [String, Array<String>] the new text (or lines)
      # @param from [String] label for the original side
      # @param to [String] label for the new side
      # @return [String] unified diff including headers and @@ hunks
      #
      # @example
      #   puts YS1::Diff.unified("a\nb\nc", "a\nx\nc", from: "old", to: "new")
      #   # --- old
      #   # +++ new
      #   # @@ -1,3 +1,3 @@
      #   #  a
      #   # -b
      #   # +x
      #   #  c
      def unified(old, new, from: "a", to: "b")
        ops = lines(old, new)
        header = "--- #{from}\n+++ #{to}"
        body = format_hunks(ops)
        return "#{header}\n#{body}" unless body.empty?

        header
      end

      private

      # Normalizes input into an array of lines without trailing newlines.
      #
      # @param text [String, Array<String>]
      # @return [Array<String>]
      def to_lines(text)
        return text.map(&:chomp) if text.is_a?(Array)

        text.to_s.lines.map(&:chomp)
      end

      # Builds the LCS length table for two line arrays.
      #
      # @param old_lines [Array<String>] the original lines
      # @param new_lines [Array<String>] the new lines
      # @return [Array<Array<Integer>>] the (n+1)x(m+1) LCS table
      def lcs_table(old_lines, new_lines)
        table = Array.new(old_lines.length + 1) { Array.new(new_lines.length + 1, 0) }

        old_lines.each_index do |row|
          new_lines.each_index do |col|
            table[row + 1][col + 1] = lcs_cell(table, old_lines, new_lines, row, col)
          end
        end

        table
      end

      # Computes one LCS cell from its neighbours.
      #
      # @param table [Array<Array<Integer>>] the table being filled
      # @param old_lines [Array<String>] the original lines
      # @param new_lines [Array<String>] the new lines
      # @param row [Integer] current row index
      # @param col [Integer] current column index
      # @return [Integer] the LCS length at this cell
      def lcs_cell(table, old_lines, new_lines, row, col)
        return table[row][col] + 1 if old_lines[row] == new_lines[col]

        [table[row + 1][col], table[row][col + 1]].max
      end

      # Walks the LCS table backwards producing [op, line] pairs.
      #
      # @param table [Array<Array<Integer>>] the LCS table
      # @param old_lines [Array<String>] the original lines
      # @param new_lines [Array<String>] the new lines
      # @return [Array<Array(String, String)>] ops in forward order
      def backtrack(table, old_lines, new_lines)
        ops = []
        row = old_lines.length
        col = new_lines.length

        while row.positive? || col.positive?
          op, row, col = next_op(table, old_lines, new_lines, row, col)
          ops << op
        end

        ops.reverse
      end

      # Determines the next operation while backtracking.
      #
      # @param table [Array<Array<Integer>>] the LCS table
      # @param old_lines [Array<String>] the original lines
      # @param new_lines [Array<String>] the new lines
      # @param row [Integer] current row index
      # @param col [Integer] current column index
      # @return [Array(Array(String, String), Integer, Integer)]
      #   the op and the next row/col indices
      def next_op(table, old_lines, new_lines, row, col)
        return [["=", old_lines[row - 1]], row - 1, col - 1] if match?(old_lines, new_lines, row, col)
        return [["+", new_lines[col - 1]], row, col - 1] if take_new?(table, row, col)

        [["-", old_lines[row - 1]], row - 1, col]
      end

      # Returns true when the current lines are equal.
      #
      # @param old_lines [Array<String>] the original lines
      # @param new_lines [Array<String>] the new lines
      # @param row [Integer] current row index
      # @param col [Integer] current column index
      # @return [Boolean]
      def match?(old_lines, new_lines, row, col)
        row.positive? && col.positive? && old_lines[row - 1] == new_lines[col - 1]
      end

      # Returns true when the new side should advance next.
      #
      # @param table [Array<Array<Integer>>] the LCS table
      # @param row [Integer] current row index
      # @param col [Integer] current column index
      # @return [Boolean]
      def take_new?(table, row, col)
        col.positive? && (row.zero? || table[row][col - 1] >= table[row - 1][col])
      end

      # Renders ops as unified-diff hunk lines.
      #
      # @param ops [Array<Array(String, String)>]
      # @return [String]
      def format_hunks(ops)
        return "" if ops.none? { |op, _| op != "=" }

        lines = ops.map do |op, line|
          op == "=" ? " #{line}" : "#{op}#{line}"
        end
        "@@ -1,#{ops.count { |op, _| op != "=" }} +1,#{ops.count { |op, _| op != "=" }} @@\n" \
          + lines.join("\n")
      end
    end
  end
end
