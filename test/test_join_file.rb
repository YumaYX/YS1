# frozen_string_literal: true

require_relative "helper"
require "tempfile"

class TestYS1JoinFile < Minitest::Test
  def with_tempfile(lines)
    file = Tempfile.new("ys1_join")
    file.write(lines.join("\n"))
    file.close
    yield(file.path)
  ensure
    file.unlink
  end

  def test_cross_files_with_block
    with_tempfile(%w[A B]) do |f1|
      with_tempfile(%w[1 2]) do |f2|
        result = []

        YS1::Join.cross_files(f1, f2) do |a, b|
          result << "#{a}#{b}"
        end

        assert_equal(
          %w[A1 A2 B1 B2],
          result
        )
      end
    end
  end

  def test_cross_files_returns_enumerator
    with_tempfile(["X"]) do |f1|
      with_tempfile(%w[Y Z]) do |f2|
        enum = YS1::Join.cross_files(f1, f2)

        assert_instance_of(Enumerator, enum)
        assert_equal(
          %w[XY XZ],
          enum.map { |a, b| "#{a}#{b}" }
        )
      end
    end
  end

  def test_cross_files_with_empty_file
    with_tempfile(["A"]) do |f1|
      with_tempfile([]) do |f2|
        result = []

        YS1::Join.cross_files(f1, f2) do |values|
          result << values
        end

        assert_equal([], result)
      end
    end
  end
end
