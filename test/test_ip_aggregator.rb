# frozen_string_literal: true

require_relative("helper")

class TestYS1IPAggregator < Minitest::Test
  def test_ip_to_u32_and_back
    ip = "192.168.1.1"
    num = YS1::IPAggregator.ip_to_u32(ip)
    back = YS1::IPAggregator.u32_to_ip(num)

    assert_equal(ip, back)
  end

  def test_continuous
    assert(YS1::IPAggregator.continuous?([1, 2, 3, 4]))
    refute(YS1::IPAggregator.continuous?([1, 2, 4, 5]))
  end

  def test_aligned
    assert(YS1::IPAggregator.aligned?(8, 4))
    refute(YS1::IPAggregator.aligned?(7, 4))
  end

  def test_aggregate_single_ip
    ips = ["10.0.0.1"]
    cidrs = YS1::IPAggregator.aggregate_ips(ips)

    assert_equal(1, cidrs.length)
    assert_equal("10.0.0.1", cidrs[0].addr)
    assert_equal(32, cidrs[0].prefix)
  end

  def test_aggregate_basic_range
    ips = ["10.0.0.1", "10.0.0.2", "10.0.0.3", "10.0.0.4"]
    cidrs = YS1::IPAggregator.aggregate_ips(ips)

    assert_equal(3, cidrs.length)
    assert_equal("10.0.0.1", cidrs[0].addr)
    assert_equal(32, cidrs[0].prefix)
  end

  def test_aggregate_full_range
    ips = (1..8).map { |i| "10.0.0.#{i}" }
    cidrs = YS1::IPAggregator.aggregate_ips(ips)

    assert_equal(4, cidrs.length)
    assert_equal("10.0.0.1", cidrs[0].addr)
    assert_equal(32, cidrs[0].prefix)

    assert_equal("10.0.0.4", cidrs[2].addr)
    assert_equal(30, cidrs[2].prefix)
  end

  def test_aggregate_with_gaps
    ips = ["10.0.0.1", "10.0.0.2", "10.0.0.4"]
    cidrs = YS1::IPAggregator.aggregate_ips(ips)

    assert_equal(3, cidrs.length)

    assert_equal("10.0.0.2", cidrs[1].addr)
    assert_equal(32, cidrs[1].prefix)

    assert_equal("10.0.0.4", cidrs[2].addr)
    assert_equal(32, cidrs[2].prefix)
  end

  def test_aggregate_unaligned
    ips = ["10.0.0.2", "10.0.0.3"]
    cidrs = YS1::IPAggregator.aggregate_ips(ips)

    assert_equal(1, cidrs.length)
    assert_equal("10.0.0.2", cidrs[0].addr)
    assert_equal(31, cidrs[0].prefix)
  end

  def test_cidrs_to_acl
    raw = [
      YS1::IPAggregator::Cidr.new("10.0.0.1", 32),
      YS1::IPAggregator::Cidr.new("10.0.0.0", 24)
    ]

    acl = YS1::IPAggregator.cidrs_to_acl(raw)

    expected = ["host 10.0.0.1", "10.0.0.0 255.255.255.0"]

    assert_equal(expected, acl)
  end
end
