# test/test_path.rb
# frozen_string_literal: true

require_relative "helper"
class TestYS1Path < Minitest::Test
  def setup
    @dir = Dir.mktmpdir
    @pwd = Dir.pwd
    Dir.chdir(@dir)

    File.write("a.rb", "")
    File.write("b.rb", "")
    File.write("c.txt", "")
  end

  def teardown
    Dir.chdir(@pwd)
    FileUtils.remove_entry(@dir)
  end

  def test_flatten_simple
    result = YS1::Path.file_list("a.rb", "b.rb").sort
    assert_equal(["a.rb", "b.rb"], result)
  end

  def test_flatten_nested_arrays
    result = YS1::Path.file_list("a.rb", ["b.rb", ["c.txt"]]).sort
    assert_equal(["a.rb", "b.rb", "c.txt"], result)
  end

  def test_glob_expansion
    result = YS1::Path.file_list("*.rb").sort
    assert_equal(["a.rb", "b.rb"], result)
  end

  def test_mixed_inputs
    result = YS1::Path.file_list("a.rb", ["*.txt"]).sort
    assert_equal(["a.rb", "c.txt"], result)
  end

  def test_empty_input
    result = YS1::Path.file_list
    assert_equal([], result)
  end
end
