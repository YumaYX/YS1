# frozen_string_literal: true

module YS1
  # Provides utility methods for extracting and processing
  # fenced code blocks (``` style) from a given text.
  module CodeBlock
    class << self
      # rubocop:disable Metrics/MethodLength

      # Extracts all triple-backtick code blocks from the given text.
      #
      # A block starts with a line beginning with ``` and ends with a line
      # that contains only ``` (optionally followed by whitespace).
      #
      # @param text [String] the input text containing zero or more code blocks
      # @return [Array<String>] an array of full code block strings,
      #   including the opening and closing backticks
      def to_arr_from(text)
        blocks = []
        buffer = nil

        text.each_line do |line|
          if buffer
            buffer << line
            if line.match?(/^```\s*\z/)
              blocks << buffer
              buffer = nil
            end
          elsif line.start_with?("```")
            buffer = line.to_s
          end
        end

        blocks
      end
      # rubocop:enable Metrics/MethodLength

      # Returns the inner body of a code block, excluding the
      # opening and closing triple backtick lines.
      #
      # @param block [String, nil] a full code block string
      # @return [String, nil] the content inside the code block,
      #   an empty string if the block has no body,
      #   or nil if the input is nil
      def body(block)
        return nil if block.nil?

        block.to_s.chomp.sub(/\A.*?```[^\n]*\n/m, "").sub(/```.*\z/m, "")
      end
    end
  end
end
