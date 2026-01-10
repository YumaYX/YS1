# frozen_string_literal: true

require_relative "helper"

class TestYS1HashToDynamicClass < Minitest::Test
  def setup
    @ruby_info = { "version" => "4.0.0", "release_date" => "2025-12-25" }
  end

  def test_to_dynamic_class
    instance = @ruby_info.to_dynamic_class.new

    @ruby_info.each do |key, value|
      assert_equal(value, instance.send(key))
    end
  end

  def test_extra
    klass = @ruby_info.to_dynamic_class

    klass.define_method(:new_method) do
      "ver. #{version}"
    end

    assert_equal("ver. 4.0.0", klass.new.new_method)
  end
end
