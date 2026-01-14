# frozen_string_literal: true

require_relative "helper"

class TestYS1Join < Minitest::Test
  def test_cross_with_block
    result = []

    YS1::Join.cross(["A", "B"], ["1", "2"]) do |a, b|
      result << "#{a}#{b}"
    end

    assert_equal(["A1", "A2", "B1", "B2"], result)
  end

  def test_cross_returns_enumerator_when_no_block
    enum = YS1::Join.cross(["A", "B"], ["1", "2"])

    assert_instance_of(Enumerator, enum)
    assert_equal(
      ["A1", "A2", "B1", "B2"],
      enum.map { |a, b| "#{a}#{b}" }
    )
  end

  def test_cross_with_three_arrays
    result = []

    YS1::Join.cross(["A"], ["1", "2"], ["x", "y"]) do |a, b, c|
      result << "#{a}-#{b}-#{c}"
    end

    assert_equal(
      ["A-1-x", "A-1-y", "A-2-x", "A-2-y"],
      result
    )
  end

  def test_cross_with_single_array
    result = []

    YS1::Join.cross(["A", "B"]) do |a|
      result << a
    end

    assert_equal([["A"], ["B"]], result)
  end

  def test_cross_with_empty_array
    result = []

    YS1::Join.cross(["A", "B"], []) do |values|
      result << values
    end

    assert_equal([], result)
  end
end