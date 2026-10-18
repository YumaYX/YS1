# frozen_string_literal: true

require_relative "helper"

class TestYS1Report < Minitest::Test
  def setup
    @dir = Dir.mktmpdir
  end

  def teardown
    FileUtils.rm_rf(@dir)
  end

  def test_save_and_load
    path = File.join(@dir, "obj.dat")
    YS1::Report.save({ key: true }, path)

    assert_equal({ key: true }, YS1::Report.load(path))
  end

  def test_save_returns_path
    path = File.join(@dir, "obj.dat")

    assert_equal(path, YS1::Report.save([1, 2, 3], path))
  end

  def test_save_and_load_default_name
    Dir.chdir(@dir) do
      YS1::Report.save({ n: 1 })

      assert_equal({ n: 1 }, YS1::Report.load)
    end
  end

  def test_load_missing_raises
    assert_raises(Errno::ENOENT) { YS1::Report.load(File.join(@dir, "none.dat")) }
  end
end
