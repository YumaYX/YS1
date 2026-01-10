# frozen_string_literal: true

require_relative("helper")
require "minitest/autorun"
require "fileutils"
require "tmpdir"

class TestYS1FileBlockSplitter < Minitest::Test
  # Set up a temporary test directory and a sample file
  def setup
    @test_dir = Dir.mktmpdir("ys1_test_")
    @file_path = File.join(@test_dir, "test_file.txt")
    File.write(@file_path,
               ["HEADER 1", "line a1", "line a2",
                "HEADER 2", "line b1", "line b2", "line b3",
                "HEADER 3", "line c1"].join("\n"))
  end

  # Clean up the temporary test directory
  def teardown
    FileUtils.rm_rf(@test_dir)
  end

  # Test splitting file by headers and processing each block
  def test_split_and_process_blocks
    processor = YS1::FileBlockSplitter.new(@file_path) { |line| line.start_with?("HEADER") }

    processor.split_into_blocks

    processed_paths = []
    processor.process_blocks do |path|
      processed_paths << path
      lines = File.readlines(path).map(&:chomp)

      # Each block file should not be empty
      assert(lines.any?, "Block file should not be empty")

      # First line of each block should be a HEADER
      assert_match(/^HEADER/, lines.first)
    end

    # There should be 3 blocks corresponding to the 3 headers
    assert_equal(3, processed_paths.size)
  end

  # Test splitting file on empty lines
  def test_split_on_empty_line
    # Append an empty line to the file
    File.open(@file_path, "a") { |f| f.puts("") }

    processor = YS1::FileBlockSplitter.new(@file_path) do |line|
      line.strip.empty?
    end

    processor.split_into_blocks

    all_blocks = []
    processor.process_blocks do |path|
      all_blocks << File.readlines(path)
    end

    # Each block should contain at least one line
    assert(all_blocks.all?(&:any?), "All blocks should contain lines")
  end
end
