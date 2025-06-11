# frozen_string_literal: true

require_relative "helper"
require "fileutils"
require "tmpdir"

class TestListFiles < Minitest::Test
  def setup
    @tmpdir = Dir.mktmpdir
    @original_dir = Dir.pwd
    Dir.chdir(@tmpdir)

    File.write("a.txt", "hello world")
    File.write("b.rb", "puts 'ruby'")
    File.open("bin.dat", "wb") { |f| f.write("\x00\x01\x02\x03") }
  end

  def teardown
    Dir.chdir(@original_dir)
    FileUtils.remove_entry(@tmpdir)
  end

  def test_text_format_with_text_file
    result = YS1::ListFiles.text_format("a.txt")
    assert_includes(result, "# file name : a.txt")
    assert_includes(result, "hello world")
  end

  def test_text_format_with_binary_file
    result = YS1::ListFiles.text_format("bin.dat")
    assert_includes(result, "# file name : bin.dat")
    refute_includes(result, "\x00")
  end

  def test_run_creates_listfiles_md
    File.write(".listfilesignore", "b.rb\n")

    cli = YS1::ListFiles::CLI.new
    cli.run

    assert File.exist?("listfiles.md")
    output = File.read("listfiles.md")

    assert_includes(output, "a.txt")
    refute_includes(output, "b.rb")
    assert_includes(output, "# file name : a.txt")
  end
end
