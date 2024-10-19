# frozen_string_literal: true

require_relative "helper"

class TestYS1JTable < Minitest::Test
  def setup
    columns = ("a".."c").to_a
    @jtable = YS1::JTable.new(columns)
  end

  def test_add_data
    @jtable.add_data("a", "a")
    @jtable.add_data("b", "b")
    @jtable.add_data("c", "c")
    assert_equal({ a: ["a"], b: ["b"], c: ["c"] }, @jtable.data)
  end

  def test_cross_join
    @jtable.add_data("a", "a-data")
    @jtable.add_data("a", "a-data2")
    @jtable.add_data("b", "b-data")
    @jtable.add_data("b", "b-data2")
    @jtable.add_data("c", "c-data")
    cross_join = @jtable.cross_join

    assert_equal(4, cross_join.length) # 2 x 2 x 1
    assert(cross_join.include?(%w[a-data2 b-data2 c-data]))
  end

  def test_to_h
    data = YS1::JTable.to_h("testdata/jtable/jtable.csv")
    assert_equal(Hash, data.class)
    assert_equal(2, data.length)
    assert_equal(%w[1 2], data.keys)
  end
end
