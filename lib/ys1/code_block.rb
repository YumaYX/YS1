# frozen_string_literal: true

module YS1
  # Provides utility methods for extracting and processing
  # fenced code blocks (``` style) from a given text.
  module CodeBlock
    # Removes surrounding Markdown-style code block fences from a string.
    OPENING_FENCE = /\A[ \t]*```[a-zA-Z]*\n?/
    # Removes trailing closing fence.
    TRAILING_FENCE = /\n?```[ \t]*\z/
    # Matches a line that is only a closing fence.
    CLOSING_LINE = /^```\s*\z/
    # Matches the opening fence line of a code block.
    FENCE_OPEN_LINE = /\A.*?```[^\n]*\n/m
    # Matches the closing fence of a code block.
    FENCE_CLOSE = /```.*\z/m

    class << self
      # Removes surrounding Markdown-style code block fences from a string.
      #
      # This method strips leading and trailing triple backtick (```) markers,
      # optionally including a language identifier (e.g., ```ruby), from the input.
      #
      # @param str [String] the input string that may contain code block fences
      # @return [String] the string with code block fences removed
      #
      # @example With language specifier
      #   strip_code_block("```ruby\nputs 'hi'\n```")
      #   # => "puts 'hi'"
      #
      # @example Without language specifier
      #   strip_code_block("```\nhello\n```")
      #   # => "hello"
      #
      # @example No code block
      #   strip_code_block("plain text")
      #   # => "plain text"
      def strip_code_block(str)
        str
          .sub(OPENING_FENCE, "")
          .sub(TRAILING_FENCE, "")
      end

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
          buffer = process_line(line, blocks, buffer)
        end

        blocks
      end

      # Returns the inner body of a code block, excluding the
      # opening and closing triple backtick lines.
      #
      # @param block [String, nil] a full code block string
      # @return [String, nil] the content inside the code block,
      #   an empty string if the block has no body,
      #   or nil if the input is nil
      def body(block)
        return nil if block.nil?

        block.to_s.chomp.sub(FENCE_OPEN_LINE, "").sub(FENCE_CLOSE, "")
      end

      private

      # Processes a single line during code block extraction.
      #
      # @param line [String] current line
      # @param blocks [Array<String>] accumulated complete blocks
      # @param buffer [String, nil] current in-progress block, or nil
      # @return [String, nil] updated buffer state
      def process_line(line, blocks, buffer)
        return line if buffer.nil? && line.start_with?("```")
        return buffer unless buffer

        buffer << line
        return buffer unless line.match?(CLOSING_LINE)

        blocks << buffer
        nil
      end
    end
  end
end
