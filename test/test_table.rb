# frozen_string_literal: true

require_relative "helper"

class TestYS1Table < Minitest::Test
  HASHES_ROWS = [
    { "id" => "1", "name" => "Alice" },
    { "id" => "2", "name" => "Bob" }
  ].freeze

  EXPECTED_HASHES = <<~TABLE.chomp
    id | name
    --+-----
    1  | Alice
    2  | Bob
  TABLE

  def test_format_hashes
    assert_equal(EXPECTED_HASHES, YS1::Table.format(HASHES_ROWS))
  end

  def test_format_arrays_with_headers
    result = YS1::Table.format([[1, "a"], [2, "bb"]], headers: %w[n x])
    expected = <<~TABLE.chomp
      n | x
      -+--
      1 | a
      2 | bb
    TABLE

    assert_equal(expected, result)
  end

  def test_format_arrays_without_headers
    result = YS1::Table.format([%w[a bb], %w[ccc d]])
    expected = <<~TABLE.chomp
      a   | bb
      ccc | d
    TABLE
    assert_equal(expected, result)
  end

  def test_empty_raises
    assert_raises(ArgumentError) { YS1::Table.format([]) }
  end

  def test_empty_with_headers
    result = YS1::Table.format([], headers: %w[a b])
    expected = "a | b\n-+-"

    assert_equal(expected, result)
  end
end
