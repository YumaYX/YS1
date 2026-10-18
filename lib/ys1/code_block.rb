# frozen_string_literal: true

module YS1
  # Provides utility methods for extracting and processing
  # fenced code blocks (``` style) from a given text.
  module CodeBlock
    # Matches one fenced code block, including the opening and closing
    # fences. Shared by {.blocks} and {.strip_all}.
    BLOCK_PATTERN = /^```[^\n]*\n(?:[^\n]*\n)*?^```[ \t]*(?:\n|\z)/m

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
      #   strip("```ruby\nputs 'hi'\n```")
      #   # => "puts 'hi'"
      #
      # @example Without language specifier
      #   strip("```\nhello\n```")
      #   # => "hello"
      #
      # @example No code block
      #   strip("plain text")
      #   # => "plain text"
      def strip(str)
        str
          .sub(/\A[ \t]*```[a-zA-Z]*\n?/, "")
          .sub(/\n?```[ \t]*\z/, "")
      end

      # Extracts all triple-backtick code blocks from the given text.
      #
      # A block starts with a line beginning with ``` and ends with a line
      # that contains only ``` (optionally followed by whitespace).
      #
      # @param text [String] the input text containing zero or more code blocks
      # @return [Array<String>] an array of full code block strings,
      #   including the opening and closing backticks
      def blocks(text)
        text.scan(BLOCK_PATTERN)
      end

      # Extracts the language tag of every fenced code block in the text.
      #
      # @param text [String] the input text containing zero or more code blocks
      # @return [Array<String>] language tags (empty string when unspecified)
      #
      # @example
      #   YS1::CodeBlock.languages("```ruby\nx\n```\n```\ny\n```")
      #   # => ["ruby", ""]
      def languages(text)
        blocks(text).map { |block| language(block) }
      end

      # Extracts the inner body of every fenced code block in the text.
      #
      # @param text [String] the input text containing zero or more code blocks
      # @return [Array<String>] bodies without the surrounding fences
      #
      # @example
      #   YS1::CodeBlock.bodies("```ruby\nputs 1\n```")
      #   # => ["puts 1\n"]
      def bodies(text)
        blocks(text).map { |block| body(block) }
      end

      # Replaces every fenced code block with its inner body.
      #
      # @param text [String] the input text containing zero or more code blocks
      # @return [String] the text with all fences removed
      #
      # @example
      #   YS1::CodeBlock.strip_all("before\n```ruby\nx\n```\nafter")
      #   # => "before\nx\nafter"
      def strip_all(text)
        text.gsub(BLOCK_PATTERN) do |block|
          body(block)
        end
      end

      # Returns the language tag of a single fenced code block.
      #
      # @param block [String] a full code block string
      # @return [String] the language tag (empty string when unspecified)
      #
      # @example
      #   YS1::CodeBlock.language("```ruby\nx\n```")
      #   # => "ruby"
      def language(block)
        block[/\A[ \t]*```([a-zA-Z]*)/, 1].to_s
      end

      # Returns the inner body of a code block.
      #
      # @param block [String, nil] a full code block string
      # @return [String, nil] the body, or nil when +block+ is nil
      def body(block)
        return nil if block.nil?

        block.lines[1..-2].join
      end
    end
  end
end
