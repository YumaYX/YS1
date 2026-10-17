# frozen_string_literal: true

require_relative "helper"

class TestYS1Integer < Minitest::Test
  def test_ipv4mask24
    assert_equal "255.255.255.0", 24.ipv4mask
  end

  def test_ipv4mask32
    assert_equal "255.255.255.255", 32.ipv4mask
  end

  def test_ipv4mask0
    assert_equal "0.0.0.0", 0.ipv4mask
  end

  def test_ipv4mask_out_of_range
    assert_raises(ArgumentError) do
      33.ipv4mask
    end
  end
end
