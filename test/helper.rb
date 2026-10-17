# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "ys1"

require "minitest/autorun"
require "tempfile"

# Shared helpers for the test suite.
module TestHelpers
  # Yields the path of a temporary file containing +lines+ joined by newlines.
  #
  # The file is closed and removed once the block returns.
  #
  # @param lines [Array<String>, String] lines to write
  # @param name [String] temporary file base name
  # @yieldparam path [String] path to the temporary file
  # @return [void]
  def with_tempfile(lines, name: "ys1")
    file = Tempfile.new(name)
    file.write(Array(lines).join("\n"))
    file.rewind
    yield file.path
  ensure
    file&.close
    file&.unlink
  end
end

Minitest::Test.include(TestHelpers)
