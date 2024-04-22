# frozen_string_literal: true

require_relative "helper"
require "json"

class TestYs1CsvConverter < Minitest::Test
  def setup
    @test_input_dir = "testdata/csv_converter"
  end

  def teardown
    filenames = Dir.glob("#{@test_input_dir}/*.json")
    filenames.map { |file| File.delete(file) }
  end

  def test_csv_to_hash
    expect_hash = {
      "Ruby" => { "name" => "Ruby", "id" => "0" },
      "Python" => { "name" => "Python", "id" => "1" }
    }

    assert_equal(expect_hash, Ys1::CsvConverter.csv_to_hash("#{@test_input_dir}/csv_to_json.csv"))
  end

  def test_csv_to_hash_with_block
    expect = { "Ruby" => 0, "Python" => 1 }
    actual = Ys1::CsvConverter.csv_to_hash("#{@test_input_dir}/csv_to_json.csv") do |row|
      row["id"].to_i
    end
    assert_equal(expect, actual)
  end

  def test_csv_to_array
    expect_array = [{ "name" => "Ruby", "id" => "0" }, { "name" => "Python", "id" => "1" }]

    assert_equal(expect_array, Ys1::CsvConverter.csv_to_array("#{@test_input_dir}/csv_to_json.csv"))
  end

  def test_generate_json_file_array
    filenames = Dir.glob("#{@test_input_dir}/*.csv")
    expect_array = '[{"name":"Ruby","id":"0"},{"name":"Python","id":"1"}]'

    filenames.map do |filename|
      Ys1::CsvConverter.generate_json_file(filename, :array)

      assert_equal(expect_array, File.read("testdata/csv_converter/csv_to_json.json"))
    end
  end

  def test_generate_json_file_array_hash
    filenames = Dir.glob("#{@test_input_dir}/*.csv")

    filenames.map do |filename|
      Ys1::CsvConverter.generate_json_file(filename, :hash)
      expect_hash = '{"Ruby":{"name":"Ruby","id":"0"},"Python":{"name":"Python","id":"1"}}'

      assert_equal(expect_hash, File.read("testdata/csv_converter/csv_to_json.json"))
    end
  end
end
