# frozen_string_literal: true

require_relative "helper"

class TestYS1LazyAccessor < Minitest::Test
  def setup
    @obj = Object.new

    @obj.extend(YS1::LazyAccessor)
  end

  #
  # setter/getter
  #
  def test_accessor
    @obj.name = "Taro"

    assert_equal("Taro", @obj.name)
  end

  #
  # multiple attributes
  #
  def test_multiple_attributes
    @obj.name = "Taro"
    @obj.age = 20

    assert_equal("Taro", @obj.name)
    assert_equal(20, @obj.age)
  end

  #
  # respond_to? before setter
  #
  def test_respond_to_before_assignment
    assert_equal(false, @obj.respond_to?(:name))
  end

  #
  # respond_to? after setter
  #
  def test_respond_to_after_assignment
    @obj.name = "Taro"

    assert_equal(true, @obj.respond_to?(:name))
  end

  #
  # setter always available
  #
  def test_respond_to_setter
    assert_equal(true, @obj.respond_to?(:name=))
  end

  #
  # getter without assignment
  #
  def test_unknown_getter
    assert_raises(NoMethodError) do
      @obj.name
    end
  end

  #
  # singleton methods are generated lazily
  #
  def test_singleton_methods_generated
    assert_equal(false, @obj.singleton_methods.include?(:name))
    assert_equal(false, @obj.singleton_methods.include?(:name=))

    @obj.name = "Taro"

    assert_equal(true, @obj.singleton_methods.include?(:name))
    assert_equal(true, @obj.singleton_methods.include?(:name=))
  end

  #
  # values are stored in instance variables
  #
  def test_instance_variable_storage
    @obj.name = "Taro"

    assert_equal([:@name], @obj.instance_variables)
    assert_equal("Taro", @obj.instance_variable_get(:@name))
  end
end
