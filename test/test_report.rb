# frozen_string_literal: true

require_relative "helper"

class TestYS1Report < Minitest::Test
  def setup
    @temporary_directory = Dir.mktmpdir
  end

  def teardown
    FileUtils.rm_rf(@temporary_directory) if File.exist?(@temporary_directory)
  end

  def test_save_and_open
    hash = { key: true }
    data_file = "#{@temporary_directory}/obj.dat"

    YS1::Report.save(hash, data_file)

    report = YS1::Report.open(data_file)
    assert(report[:key])
  end
end
