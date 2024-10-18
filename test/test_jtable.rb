# frozen_string_literal: true

require_relative "helper"

class TestYS1JTable < Minitest::Test
  def setup
    columns = ("a".."c").to_a
    @jtable = YS1::JTable.new(columns)
  end

  def test_add_data
    @jtable.add_data("a", "a")
    @jtable.add_data("b", "b" * 2)
    @jtable.add_data("c", "c" * 3)
    assert_equal({ a: ["a"], b: ["bb"], c: ["ccc"] }, @jtable.data)
  end

  def test_table_2_data
    data = YS1::JTable.table_2_data("testdata/jtable/jtable.csv")
    assert_equal(Hash, data.class)
    assert_equal(2, data.length)
    assert_equal(%w[1 2], data.keys)
  end
end
