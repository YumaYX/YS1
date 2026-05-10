# frozen_string_literal: true

require "tempfile"
require_relative "helper"

class TestYS1CSV < Minitest::Test
  def setup
    # Create a temporary file for CSV data
    @temp_file = Tempfile.new(["test", ".csv"])
    @file_path = @temp_file.path

    # Write dummy CSV content: Header1,Header2\nValue1A,Value1B\nValue2A,Value2B
    @csv_content = <<~CSV
      Header1,Header2
      Apple,100
      Banana,200
    CSV
    @temp_file.write(@csv_content)
    @temp_file.close # Close the file so YS1::CSV can read it
  end

  def teardown
    # Clean up the temporary file
    @temp_file&.unlink
  end

  # Test initialization
  def test_initialization
    csv_reader = YS1::CSV.new(@file_path)
    assert_equal(@file_path, csv_reader.file_path)
  end

  # rubocop:disable Metrics/AbcSize
  # Test the read method
  def test_read
    csv_reader = YS1::CSV.new(@file_path)
    data = csv_reader.read

    # Verify it's an Array of Hashes
    assert_instance_of(Array, data)
    assert_equal(2, data.length)

    # Verify content structure
    assert_equal("Apple", data[0]["Header1"])
    assert_equal("100", data[0]["Header2"])
    assert_equal("Banana", data[1]["Header1"])
    assert_equal("200", data[1]["Header2"])
  end
  # rubocop:enable Metrics/AbcSize

  # Test the to_json method (and dependency on read)
  def test_to_json
    csv_reader = YS1::CSV.new(@file_path)
    json_output = csv_reader.to_json

    # Parse the JSON back to verify structure
    parsed_data = JSON.parse(json_output)

    assert_instance_of(Array, parsed_data)
    assert_equal(2, parsed_data.length)

    # Check content after JSON serialization/deserialization
    assert_equal("Apple", parsed_data[0]["Header1"])
    assert_equal("100", parsed_data[0]["Header2"])
  end
end
