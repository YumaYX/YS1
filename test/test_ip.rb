# frozen_string_literal: true

require_relative "helper"

class TestYS1IP < Minitest::Test
  def test_netmask32
    assert_equal "255.255.255.255", YS1::IP.netmask(32)
  end

  def test_netmask24
    assert_equal "255.255.255.0", YS1::IP.netmask(24)
  end

  def test_netmask16
    assert_equal "255.255.0.0", YS1::IP.netmask(16)
  end

  def test_netmask8
    assert_equal "255.0.0.0", YS1::IP.netmask(8)
  end

  def test_netmask0
    assert_equal "0.0.0.0", YS1::IP.netmask(0)
  end

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
