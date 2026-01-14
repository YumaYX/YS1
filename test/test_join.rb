# frozen_string_literal: true

require_relative "helper"

class TestYS1Join < Minitest::Test
  def test_basic_product
    result = []
    YS1::Join.cross([1, 2], %i[a b]) { |x| result << x }

    assert_equal(
      [[1, :a], [1, :b], [2, :a], [2, :b]],
      result
    )
  end

  def test_multiple_arrays
    result = []
    YS1::Join.cross([1, 2], [:a], [true, false]) { |x| result << x }

    assert_equal(
      [[1, :a, true], [1, :a, false], [2, :a, true], [2, :a, false]],
      result
    )
  end

  def test_returns_enumerator_without_block
    enum = YS1::Join.cross([1, 2], %i[a b])

    assert_instance_of Enumerator, enum
    assert_equal(
      [[1, :a], [1, :b], [2, :a], [2, :b]],
      enum.to_a
    )
  end

  def test_no_arguments
    result = []
    YS1::Join.cross { |x| result << x }

    assert_equal([[]], result)
  end

  def test_empty_array
    result = []
    YS1::Join.cross([1, 2], []) { |x| result << x }

    assert_equal([], result)
  end
end
