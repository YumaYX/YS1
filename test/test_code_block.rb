# frozen_string_literal: true

require_relative "helper"

class TestYS1CodeBlock < Minitest::Test
  def test_to_arr_from
    makrdown_example = <<~CODEBLOCKS
      # Ruby
      ```ruby
      puts "hello"
      ```
      # python
      ```python
      print("hello")
      ```
    CODEBLOCKS

    expect = ["```ruby\nputs \"hello\"\n```\n", "```python\nprint(\"hello\")\n```\n"]
    assert_equal(expect, YS1::CodeBlock.to_arr_from(makrdown_example))
  end

  def test_to_arr_from2
    makrdown_example = "```\n1\n```lang1\n2\n```\n3\n```lang2\n4\n```\n"

    expect = ["```\n1\n```lang1\n2\n```\n", "```lang2\n4\n```\n"]

    assert_equal(expect, YS1::CodeBlock.to_arr_from(makrdown_example))
  end

  def test_body_normal
    block = <<~CB
      ```ruby
      puts "hello"
      ```
    CB
    expect = "puts \"hello\"\n"
    assert_equal(expect, YS1::CodeBlock.body(block))
  end

  def test_body_empty
    block = <<~CB
      ```ruby
      ```
    CB
    expect = ""
    assert_equal(expect, YS1::CodeBlock.body(block))
  end

  def test_body_nil
    assert_nil(YS1::CodeBlock.body(nil))
  end
end
