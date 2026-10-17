# frozen_string_literal: true

require_relative "helper"

class TestYS1CSV < Minitest::Test
  ROWS = [
    "Header1,Header2",
    "Apple,100",
    "Banana,200"
  ].freeze

  EXPECTED = [
    { "Header1" => "Apple", "Header2" => "100" },
    { "Header1" => "Banana", "Header2" => "200" }
  ].freeze

  def test_initialization
    with_tempfile(ROWS) do |path|
      assert_equal(path, YS1::CSV.new(path).file_path)
    end
  end

  def test_read
    with_tempfile(ROWS) do |path|
      data = YS1::CSV.new(path).read

      assert_instance_of(Array, data)
      assert_equal(EXPECTED, data)
    end
  end

  def test_to_json
    with_tempfile(ROWS) do |path|
      parsed_data = JSON.parse(YS1::CSV.new(path).to_json)

      assert_instance_of(Array, parsed_data)
      assert_equal(EXPECTED, parsed_data)
    end
  end

  def test_enumerable
    with_tempfile(ROWS) do |path|
      csv = YS1::CSV.new(path)

      assert_kind_of(Enumerator, csv.each)
      assert_equal(2, csv.count)
      assert_equal(%w[Apple Banana], csv.map { |row| row["Header1"] })
    end
  end
end
