# frozen_string_literal: true

require_relative "helper"

class TestYS1IPAggregator < Minitest::Test
  def test_example1
    ips = %w[
      192.168.1.223
      192.168.1.224
      192.168.1.225
    ]

    expected = [
      ["192.168.1.223", 32],
      ["192.168.1.224", 31]
    ]

    assert_equal expected, YS1::IPAggregator.summarize_ips(ips)
  end

  def test_example2
    ips = (224..231).map { |i| "192.168.1.#{i}" }

    expected = [
      ["192.168.1.224", 29]
    ]

    assert_equal expected, YS1::IPAggregator.summarize_ips(ips)
  end

  def test_non_consecutive
    ips = %w[10.0.0.1 10.0.0.3 10.0.0.5]

    expected = [
      ["10.0.0.1", 32],
      ["10.0.0.3", 32],
      ["10.0.0.5", 32]
    ]

    assert_equal expected, YS1::IPAggregator.summarize_ips(ips)
  end

  def test_min_mask_limit
    ips = (224..231).map { |i| "192.168.1.#{i}" }

    result = YS1::IPAggregator.summarize_ips(ips, min_mask: 30)
    assert(result.all? { |(_, mask)| mask >= 30 })
    assert_equal("192.168.1.224", result[0].first)
    assert_equal("192.168.1.228", result[1].first)
  end

  def test_duplicate_ips
    ips = %w[
      192.168.0.1
      192.168.0.1
      192.168.0.2
    ]

    expected = [
      ["192.168.0.1", 32],
      ["192.168.0.2", 32]
    ]

    assert_equal expected, YS1::IPAggregator.summarize_ips(ips)
  end

  def test_multiple_entries
    input = [
      ["192.168.1.223", 32],
      ["192.168.1.224", 31]
    ]

    expected = [
      "host 192.168.1.223",
      "192.168.1.224 255.255.255.254"
    ]

    assert_equal expected, YS1::IPAggregator.cidrs_to_acl(input)
  end
end
