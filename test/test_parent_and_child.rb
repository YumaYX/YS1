# frozen_string_literal: true

require_relative "helper"

class TestYS1ParentAndChild < Minitest::Test
  # Set up a ParentAndChild instance with "Parent" as the root
  def setup
    @pac = YS1::ParentAndChild.new("Parent")
  end

  # Test adding individual children
  def test_add_child
    3.times { |index| @pac.add_child(index) }
    assert_equal(3.times.to_a, @pac.children)
  end

  # Test adding children with nested arrays
  def test_add_child_with_array
    children_with_array = [[0, 1], [2, 3, 4]]
    @pac.add_child(children_with_array)
    assert_equal(5.times.to_a, @pac.children)
  end

  # Test family with no children added
  def test_family_none_child
    assert_equal(["Parent"], @pac.family)
  end

  # Test family after adding children
  def test_family
    3.times { |index| @pac.add_child(index) }
    assert_equal(["Parent", 0, 1, 2], @pac.family)
  end
end
