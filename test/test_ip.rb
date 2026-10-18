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

  def test_netmask_invalid_prefix_negative
    assert_raises(ArgumentError) do
      YS1::IP.netmask(-1)
    end
  end

  def test_netmask_invalid_prefix_too_large
    assert_raises(ArgumentError) do
      YS1::IP.netmask(33)
    end
  end

  def test_netmask_invalid_prefix_not_integer
    assert_raises(ArgumentError) do
      YS1::IP.netmask("24")
    end
  end

  def test_cidr_accessors
    cidr = YS1::IP::Cidr.new("192.168.1.0", 24)

    assert_equal "192.168.1.0", cidr.addr
    assert_equal 24, cidr.prefix
    assert_equal "192.168.1.0/24", cidr.to_s
  end

  def test_cidr_invalid_prefix
    assert_raises(ArgumentError) do
      YS1::IP::Cidr.new("192.168.1.0", 33)
    end
  end

  def test_include_true
    assert YS1::IP.include?("10.0.0.0/24", "10.0.0.5")
  end

  def test_include_false
    refute YS1::IP.include?("10.0.0.0/24", "10.0.1.5")
  end

  def test_include_with_cidr_object
    cidr = YS1::IP::Cidr.new("10.0.0.0", 24)

    assert YS1::IP.include?(cidr, "10.0.0.99")
  end

  def test_private_true
    assert YS1::IP.private?("192.168.1.1")
    assert YS1::IP.private?("10.1.2.3")
    assert YS1::IP.private?("127.0.0.1")
    assert YS1::IP.private?("169.254.0.1")
  end

  def test_private_false
    refute YS1::IP.private?("8.8.8.8")
    refute YS1::IP.private?("1.1.1.1")
  end

  def test_private_ipv6
    assert YS1::IP.private?("::1")
    assert YS1::IP.private?("fd00::1")
    refute YS1::IP.private?("2001:4860:4860::8888")
  end

  def test_version
    assert_equal 4, YS1::IP.version("192.168.1.1")
    assert_equal 6, YS1::IP.version("::1")
  end
end
