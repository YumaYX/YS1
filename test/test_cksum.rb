# frozen_string_literal: true

require_relative "helper"

class TestYS1Cksum < Minitest::Test
  def setup
    @x = YS1::Cksum.new("testdata/cksum/a")
    @y = YS1::Cksum.new("testdata/cksum/b")
  end

  def test_hashnize
    sums = @x.hashnize
    assert_equal("2418082923", sums["a"])
    assert_equal("2454254050", sums["b"])
    assert_equal("2475711845", sums["c"])
  end

  def test_compare
    @x.hashnize
    @y.hashnize
    assert_equal(["b"], @y.compare(@x))
  end
end
