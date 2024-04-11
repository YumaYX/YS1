# frozen_string_literal: true

require_relative "parent_and_child"

module Ys1
  # The Text module for handling text extraction and transformation.
  module Text
    class << self
      # Extracts lines from the given text that match the start line pattern and
      # organizes them into ParentAndChild objects.
      #
      # @param text [String] The input text to extract lines from.
      # @param start_line [Regexp] The regular expression pattern to identify the start line.
      # @param ref_array [Array] An optional reference array to store extracted ParentAndChild objects.
      # @return [Array] An array of ParentAndChild objects representing the extracted lines.
      def extract_with_mark(text, start_line, ref_array = [])
        text.each_line do |line|
          line.chomp!
          if line =~ start_line
            ref_array << Ys1::ParentAndChild.new(line)
          elsif ref_array.any?
            ref_array.last.add_child(line)
          end
        end
        ref_array
      end

      # Extracts lines from the specified file that match the start line pattern and
      # organizes them into ParentAndChild objects.
      #
      # @param filename [String] The name of the file to read lines from.
      # @param start_line [Regexp] The regular expression pattern to identify the start line.
      # @return [Array] An array of ParentAndChild objects representing the extracted lines.
      def extract_with_mark_f(filename, start_line)
        array = []
        File.foreach(filename) { |line| extract_with_mark(line, start_line, array) }
        array
      end

      # Converts lines of text into a hash using the specified column index as the key.
      #
      # @param text [String] The input text to convert into a hash.
      # @param column_index [Integer] The index of the column to use as the key.
      # @param delimiter [String] The delimiter used to split the lines into columns.
      # @param ref_hash [Hash] An optional reference hash to store the resulting key-value pairs.
      # @param duplex [Boolean] If true, allows duplicate keys in the hash.
      # @return [Hash] The hash representing the converted lines.
      def lines_to_hash(text, column_index = 0, delimiter = " ", ref_hash = {}, duplex: false)
        text.each_line do |line|
          line_array = line.split(delimiter)
          key = line_array[column_index]
          raise "Duplicate keys in lines: #{key}" if ref_hash.key?(key) && !duplex

          ref_hash[key] = line_array
        end
        ref_hash
      end

      # Converts lines from the specified file into a hash using the specified column index as the key.
      #
      # @param filename [String] The name of the file to read lines from.
      # @param column_index [Integer] The index of the column to use as the key.
      # @param delimiter [String] The delimiter used to split the lines into columns.
      # @param duplex [Boolean] If true, allows duplicate keys in the hash.
      # @return [Hash] The hash representing the converted lines.
      def lines_to_hash_f(filename, column_index = 0, delimiter = " ", duplex: false)
        hash = {}
        File.foreach(filename) { |line| lines_to_hash(line, column_index, delimiter, hash, duplex: duplex) }
        hash
      end
    end
  end
end
