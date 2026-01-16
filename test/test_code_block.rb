# frozen_string_literal: true

require_relative "helper"

class TestYS1CodeBlock < Minitest::Test
  def test_with_language_specifier
    input = "```ruby\nputs 'hi'\n```"
    expected = "puts 'hi'"
    assert_equal(expected, YS1::CodeBlock.strip_code_block(input))
  end

  def test_without_language_specifier
    input = "```\nhello\n```"
    expected = "hello"
    assert_equal(expected, YS1::CodeBlock.strip_code_block(input))
  end

  def test_without_trailing_newline_before_closing
    input = "```js\nconsole.log(1);```"
    expected = "console.log(1);"
    assert_equal(expected, YS1::CodeBlock.strip_code_block(input))
  end

  def test_no_code_block
    input = "plain text"
    assert_equal(input, YS1::CodeBlock.strip_code_block(input))
  end

  def test_leading_and_trailing_whitespace
    input = "   ```python\nx = 1\n```   "
    expected = "x = 1"
    assert_equal(expected, YS1::CodeBlock.strip_code_block(input))
  end

  def test_only_opening_fence
    input = "```rb\nputs 'hi'"
    expected = "puts 'hi'"
    assert_equal(expected, YS1::CodeBlock.strip_code_block(input))
  end

  def test_only_closing_fence
    input = "hello\n```"
    expected = "hello"
    assert_equal(expected, YS1::CodeBlock.strip_code_block(input))
  end

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
