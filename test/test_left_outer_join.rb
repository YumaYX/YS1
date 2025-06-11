# frozen_string_literal: true

require_relative "helper"
require "tmpdir"

class TestYS1LeftOuterJoin < Minitest::Test
  def test_guess_common_keys_found
    left = { id: 1, name: "Alice" }
    right = { id: 2, age: 30 }
    assert_equal(:id, YS1::LeftOuterJoin.guess_common_keys(left, right))
  end

  def test_guess_common_keys_none
    left = { foo: 1 }
    right = { bar: 2 }
    assert_nil(YS1::LeftOuterJoin.guess_common_keys(left, right))
  end

  def with_temp_csv(left_content, right_content)
    Dir.mktmpdir do |dir|
      left_path = File.join(dir, "left.csv")
      right_path = File.join(dir, "right.csv")
      File.write(left_path, left_content)
      File.write(right_path, right_content)
      yield(left_path, right_path)
    end
  end

  def test_cli_output
    left = "id,name\n1,Alice\n2,Bob\n"
    right = "id,age\n1,30\n3,40\n"

    with_temp_csv(left, right) do |left_path, right_path|
      out, = capture_subprocess_io do
        YS1::LeftOuterJoin::CLI.new.run(left_path, right_path)
      end
      assert_includes(out, "# Key is id")
      assert_includes(out, "1,Alice,30")
      assert_includes(out, "2,Bob")
    end
  end

  def test_cli_abort_on_no_common_key
    left = "id,name\n1,Alice\n"
    right = "code,age\nX,99\n"

    with_temp_csv(left, right) do |left_path, right_path|
      err = assert_raises(SystemExit) do
        capture_subprocess_io do
          YS1::LeftOuterJoin::CLI.new.run(left_path, right_path)
        end
      end
      assert_equal(1, err.status)
    end
  end
end
