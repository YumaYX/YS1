# frozen_string_literal: true

require_relative "helper"

class TestYS1Cksum < Minitest::Test
  def setup
    @temporary_directory = Dir.mktmpdir
    result = `cksum * 2>/dev/null`
    @cksum_file = "#{@temporary_directory}/cksum.txt"
    File.write(@cksum_file, result)
  end

  def teardown
    FileUtils.rm_rf(@temporary_directory) if File.exist?(@temporary_directory)
  end

  def test_hashnize
    i = YS1::Cksum.new(@cksum_file)
    list = i.hashnize
    assert_equal(Integer, list["ys1.gemspec"].class)
  end

  def test_compare
    i = YS1::Cksum.new(@cksum_file)
    assert(i.compare(i).empty?)
  end
end
