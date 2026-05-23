# frozen_string_literal: true

require_relative "helper"

class TestYS1Integer < Minitest::Test
  def test_invalid_prefix_negative
    assert_raises(ArgumentError) do
      YS1::IP.netmask(-1)
    end
  end

  def test_invalid_prefix_too_large
    assert_raises(ArgumentError) do
      YS1::IP.netmask(33)
    end
  end

  def test_invalid_prefix_not_integer
    assert_raises(ArgumentError) do
      YS1::IP.netmask("24")
    end
  end
end
