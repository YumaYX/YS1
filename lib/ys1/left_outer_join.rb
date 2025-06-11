# frozen_string_literal: true

require "csv"

module YS1
  # Provides left outer join functionality and CLI interface.
  module LeftOuterJoin
    ##
    # Guess a common key between two hashes by intersecting their keys.
    #
    # @param left_hash [Hash, nil] the first hash to compare
    # @param right_hash [Hash, nil] the second hash to compare
    # @return [Symbol, String, nil] the first common key found, or nil if none
    def self.guess_common_keys(left_hash, right_hash)
      return nil unless left_hash && right_hash

      common = left_hash.keys & right_hash.keys
      common.first unless common.empty?
    end

    # Command-line interface for performing a left outer join.
    class CLI
      ##
      # Runs the CLI with two CSV file paths.
      #
      # @param left_csv_path [String] path to the left CSV file
      # @param right_csv_path [String] path to the right CSV file
      # @return [void]
      def run(left_csv_path, right_csv_path)
        left = Csv.to_array(left_csv_path)
        right = Csv.to_array(right_csv_path)

        common_key = LeftOuterJoin.guess_common_keys(left.first, right.first)
        abort("Error: common key not found.") unless common_key

        puts "# Key is #{common_key}."
        joined = Join.l_join(left, common_key, right, common_key)
        puts Csv.hashes_to_csv(joined)
      end
    end
  end
end
