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

  def test_write_hashes
    rows = [{ "id" => "1", "name" => "Alice" }, { "id" => "2", "name" => "Bob" }]
    file = Tempfile.new("out")
    begin
      YS1::CSV.write(file.path, rows)

      assert_equal(rows, YS1::CSV.new(file.path).read)
    ensure
      file.close
      file.unlink
    end
  end

  def test_write_arrays_with_headers
    file = Tempfile.new("out")
    begin
      YS1::CSV.write(file.path, [%w[1 Alice]], headers: %w[id name])

      assert_equal([{ "id" => "1", "name" => "Alice" }], YS1::CSV.new(file.path).read)
    ensure
      file.close
      file.unlink
    end
  end

  def test_write_empty_noop
    file = Tempfile.new("out")
    begin
      assert_nil YS1::CSV.write(file.path, [])
    ensure
      file.close
      file.unlink
    end
  end

  def test_select_columns
    with_tempfile(ROWS) do |path|
      selected = YS1::CSV.new(path).select_columns("Header1")

      assert_equal([{ "Header1" => "Apple" }, { "Header1" => "Banana" }], selected)
    end
  end

  def test_cast
    with_tempfile(ROWS) do |path|
      csv = YS1::CSV.new(path)
      csv.cast("Header2" => ->(v) { Integer(v) })

      assert_equal([100, 200], csv.map { |row| row["Header2"] })
    end
  end

  def test_to_table
    with_tempfile(ROWS) do |path|
      table = YS1::CSV.new(path).to_table

      assert_includes(table, "Header1")
      assert_includes(table, "Apple")
    end
  end

  def test_to_table_has_separator
    with_tempfile(ROWS) do |path|
      lines = YS1::CSV.new(path).to_table.split("\n")

      assert_equal("Header1 | Header2", lines[0].rstrip)
      assert_match(/\A-+\+-+\z/, lines[1])
    end
  end
end
