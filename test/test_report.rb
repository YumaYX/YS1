# frozen_string_literal: true

require_relative "helper"

class TestYS1Report < Minitest::Test
  def setup
    @temporary_directory = Dir.mktmpdir
  end

  def teardown
    [@temporary_directory, "obj.dat"].each do |garbage|
      FileUtils.rm_rf(garbage) if File.exist?(garbage)
    end
  end

  def test_save_and_open
    hash = { key: true }
    data_file = "#{@temporary_directory}/obj.dat"

    YS1::Report.save(hash, data_file)

    report = YS1::Report.open(data_file)
    assert(report[:key])
  end

  def test_save_and_open_without_args
    hash = { key: true }
    YS1::Report.save(hash)

    report = YS1::Report.open
    assert(report[:key])
  end
end
