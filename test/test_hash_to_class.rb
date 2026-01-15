# frozen_string_literal: true

require_relative "helper"

class TestYS1HashToClass < Minitest::Test
  # Set up a sample hash representing Ruby info
  def setup
    @ruby_info = { "version" => "4.0.0", "release_date" => "2025-12-25" }
  end

  # Test converting a hash to a dynamic class and checking attribute values
  def test_to_anon_class
    instance = @ruby_info.to_anon_class.new

    @ruby_info.each do |key, value|
      assert_equal(value, instance.send(key))
    end
  end

  # Test defining an additional method on the dynamic class
  def test_extra
    klass = @ruby_info.to_anon_class

    klass.define_method(:new_method) do
      "ver. #{version}"
    end

    assert_equal("ver. 4.0.0", klass.new.new_method)
  end
end
