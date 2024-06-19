# frozen_string_literal: true

require_relative "helper"
require "json"

class TestYS1Csv < Minitest::Test
  def setup
    @test_input_dir = "testdata/csv"
  end

  def teardown
    filenames = Dir.glob("#{@test_input_dir}/*.json")
    filenames.map { |file| File.delete(file) }
  end

  def test_to_hash
    expect_hash = {
      "Ruby" => { "name" => "Ruby", "id" => "0" },
      "Python" => { "name" => "Python", "id" => "1" }
    }

    assert_equal(expect_hash, YS1::Csv.to_hash("#{@test_input_dir}/csv_to_json.csv"))
  end

  def test_to_hash_with_block
    expect = { "Ruby" => 0, "Python" => 1 }
    actual = YS1::Csv.to_hash("#{@test_input_dir}/csv_to_json.csv") do |row|
      row["id"].to_i
    end
    assert_equal(expect, actual)
  end

  def test_to_array
    expect_array = [{ "name" => "Ruby", "id" => "0" }, { "name" => "Python", "id" => "1" }]

    assert_equal(expect_array, YS1::Csv.to_array("#{@test_input_dir}/csv_to_json.csv"))
  end

  def test_generate_json_file_array
    filenames = Dir.glob("#{@test_input_dir}/*.csv")
    expect_array = '[{"name":"Ruby","id":"0"},{"name":"Python","id":"1"}]'

    filenames.map do |filename|
      YS1::Csv.generate_json_file(filename, :array)
      output_name = filename.gsub(/.csv$/, ".json")
      assert_equal(expect_array, File.read(output_name))
    end
  end

  def test_generate_json_file_array_hash
    filenames = Dir.glob("#{@test_input_dir}/*.csv")
    expect_hash = '{"Ruby":{"name":"Ruby","id":"0"},"Python":{"name":"Python","id":"1"}}'

    filenames.map do |filename|
      YS1::Csv.generate_json_file(filename, :hash)
      output_name = filename.gsub(/.csv$/, ".json")
      assert_equal(expect_hash, File.read(output_name))
    end
  end
end
