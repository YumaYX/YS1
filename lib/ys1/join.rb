# frozen_string_literal: true

# YS1 module containing various functionalities.
module YS1
  # Join module providing join operations.
  module Join
    class << self
      # Performs a left join on two arrays of hashes based on specified keys.
      #
      # @param left [Array<Hash>] The left array of hashes.
      # @param left_key [Symbol, String] The key to join on from the left array.
      # @param right [Array<Hash>] The right array of hashes.
      # @param right_key [Symbol, String] The key to join on from the right array.
      # @return [Array<Hash>] The resulting array of hashes after the left join.
      def lo_join(left, left_key, right, right_key)
        duplicates_values?(right, right_key)

        t_left = Marshal.load(Marshal.dump(left))
        t_left.each do |e_left|
          hit = right.find { |r| r[right_key].to_s == e_left[left_key].to_s }
          e_left.merge!(hit) if hit
        end
        t_left
      end

      # Checks for duplicate values in an array of hashes based on a specified key.
      #
      # @param array [Array<Hash>] The array of hashes to check.
      # @param key [Symbol, String] The key to check for duplicates.
      # @raise [RuntimeError] If duplicate values are found.
      # @return [false] Returns false if no duplicates are found.
      def duplicates_values?(array, key)
        seen_values = {}
        array.each do |element|
          key_value = element[key]
          raise "Values Duplicate" if seen_values[key_value]

          seen_values[key_value] = true
        end
        false
      end
    end
  end
end
