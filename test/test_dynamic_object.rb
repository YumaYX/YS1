# frozen_string_literal: true

require_relative "helper"

class TestYS1DynamicObject < Minitest::Test
  class User
    include YS1::DynamicObject
  end

  def setup
    @user = User.new
  end

  def teardown
    @user = nil
  end

  def test_dynamic_setter_and_getter
    @user.name = "Taro"

    assert_equal("Taro", @user.name)
  end

  def test_multiple_attributes
    @user.name = "Taro"
    @user.age = 20

    assert_equal("Taro", @user.name)
    assert_equal(20, @user.age)
  end

  def test_internal_data_storage
    @user.name = "Taro"

    assert_equal({ name: "Taro" }, @user.data)
  end

  def test_respond_to_for_existing_attribute
    @user.name = "Taro"

    assert_respond_to(@user, :name)
    assert_respond_to(@user, :name=)
  end

  def test_respond_to_for_unknown_attribute
    refute_respond_to(@user, :unknown)
  end

  def test_unknown_getter_raises_error
    assert_raises(NoMethodError) do
      @user.unknown
    end
  end

  def test_setter_does_not_raise_error
    assert_silent do
      @user.email = "test@example.com"
    end
  end

  def test_instance_isolation
    user1 = User.new
    user2 = User.new

    user1.name = "Taro"
    user2.name = "Jiro"

    assert_equal("Taro", user1.name)
    assert_equal("Jiro", user2.name)
    refute_same(user1.data, user2.data)
  end
end
