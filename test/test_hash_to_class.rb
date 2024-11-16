# frozen_string_literal: true

require_relative "helper"

class TestYS1HashToClass < Minitest::Test
  def setup
    @ruby_info = { "version" => "3.3.3", "release_date" => "2024-06-12" }
  end

  def test_create_dynamic_class
    instance = YS1::HashToClass.create_dynamic_class(@ruby_info).new
    @ruby_info.each { |key, value| assert_equal(value, instance.send(key.to_sym)) }
  end

  def test_extra
    instance = YS1::HashToClass.create_dynamic_class(@ruby_info)
    instance.define_method(:new_method) do
      "ver. #{version}"
    end
    assert_equal("ver. 3.3.3", instance.new.new_method)
  end
end
