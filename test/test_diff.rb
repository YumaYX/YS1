# frozen_string_literal: true

require_relative "helper"

class TestYS1Diff < Minitest::Test
  EXPECTED_UNIFIED = <<~DIFF.chomp
    --- old
    +++ new
    @@ -1,2 +1,2 @@
     a
    -b
    +x
     c
  DIFF

  def test_lines_identical
    assert_equal([["=", "a"], ["=", "b"]], YS1::Diff.lines("a\nb", "a\nb"))
  end

  def test_lines_change
    expected = [["=", "a"], ["-", "b"], ["+", "x"], ["=", "c"]]

    assert_equal(expected, YS1::Diff.lines("a\nb\nc", "a\nx\nc"))
  end

  def test_lines_added
    assert_equal([["=", "a"], ["+", "b"]], YS1::Diff.lines("a", "a\nb"))
  end

  def test_lines_removed
    assert_equal([["=", "a"], ["-", "b"]], YS1::Diff.lines("a\nb", "a"))
  end

  def test_lines_array_input
    assert_equal([["=", "a"], ["+", "b"]], YS1::Diff.lines(["a"], %w[a b]))
  end

  def test_unified
    result = YS1::Diff.unified("a\nb\nc", "a\nx\nc", from: "old", to: "new")

    assert_equal(EXPECTED_UNIFIED, result)
  end

  def test_unified_identical
    result = YS1::Diff.unified("a", "a")

    assert_equal("--- a\n+++ b", result)
  end
end
