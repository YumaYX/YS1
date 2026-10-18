# frozen_string_literal: true

require_relative "helper"

class TestYS1Humanize < Minitest::Test
  def test_bytes_zero
    assert_equal("0 B", YS1::Humanize.bytes(0))
  end

  def test_bytes_small
    assert_equal("512 B", YS1::Humanize.bytes(512))
  end

  def test_bytes_kib
    assert_equal("1.5 KiB", YS1::Humanize.bytes(1536))
  end

  def test_bytes_mib_whole
    assert_equal("3 MiB", YS1::Humanize.bytes(1024 * 1024 * 3))
  end

  def test_bytes_negative_raises
    assert_raises(ArgumentError) { YS1::Humanize.bytes(-1) }
  end

  def test_duration_zero
    assert_equal("0s", YS1::Humanize.duration(0))
  end

  def test_duration_seconds_only
    assert_equal("45s", YS1::Humanize.duration(45))
  end

  def test_duration_full
    assert_equal("1h 2m 5s", YS1::Humanize.duration(3725))
  end

  def test_duration_minutes_only
    assert_equal("2m", YS1::Humanize.duration(120))
  end

  def test_duration_negative_raises
    assert_raises(ArgumentError) { YS1::Humanize.duration(-1) }
  end

  def test_number
    assert_equal("1,234,567", YS1::Humanize.number(1_234_567))
  end

  def test_number_small
    assert_equal("42", YS1::Humanize.number(42))
  end

  def test_number_negative
    assert_equal("-42", YS1::Humanize.number(-42))
  end
end
