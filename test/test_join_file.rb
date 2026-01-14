# frozen_string_literal: true

require_relative "helper"
require "tempfile"

class TestYS1Join < Minitest::Test
  def with_tempfile(lines)
    file = Tempfile.new("ys1")
    file.write(lines.join("\n"))
    file.rewind
    yield file.path
  ensure
    file.close
    file.unlink
  end

  def test_cross_from_files_basic
    with_tempfile(%w[1 2]) do |file1|
      with_tempfile(%w[a b]) do |file2|
        result = YS1::Join.cross_from_files(file1, file2).to_a

        assert_equal(
          [%w[1 a], %w[1 b], %w[2 a], %w[2 b]],
          result
        )
      end
    end
  end

  def test_cross_from_files_with_block
    result = []

    with_tempfile(%w[x y]) do |file1|
      with_tempfile(%w[1 2]) do |file2|
        YS1::Join.cross_from_files(file1, file2) do |combo|
          result << combo
        end
      end
    end

    assert_equal(
      [%w[x 1], %w[x 2], %w[y 1], %w[y 2]],
      result
    )
  end

  def test_cross_from_files_single_file
    with_tempfile(%w[a b c]) do |file|
      result = YS1::Join.cross_from_files(file).to_a
      assert_equal([["a"], ["b"], ["c"]], result)
    end
  end

  def test_cross_from_files_empty_file
    with_tempfile([]) do |file|
      result = YS1::Join.cross_from_files(file).to_a
      assert_equal([], result)
    end
  end
end
