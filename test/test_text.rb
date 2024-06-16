# frozen_string_literal: true

require_relative "helper"

class TestYS1Text < Minitest::Test
  def setup
    @temporary_directory = Dir.mktmpdir
  end

  def teardown
    FileUtils.rm_rf(@temporary_directory) if File.exist?(@temporary_directory)
  end

  def test_extract_with_mark
    file_content = "header0\ncontent0\nheader1\ncontent1\nheader2\ncontent2\n"
    pacs = YS1::Text.extract_with_mark(file_content, /header/)
    assert(!pacs.size.eql?(0))
    pacs.each_with_index do |pac, index|
      assert_equal("header#{index}", pac.parent)
      assert_equal("content#{index}", pac.children.first)
    end
  end

  def test_extract_with_mark_no_hit
    pacs = YS1::Text.extract_with_mark("CONTENTS", /UNIQUE/)
    assert(pacs.size.eql?(0))
  end

  def test_extract_with_mark_f
    temporary_file = "#{@temporary_directory}/header_contents.txt"
    file_content = "header0\ncontent0\nheader1\ncontent1\nheader2\ncontent2\n"
    File.write(temporary_file, file_content)

    pacs = YS1::Text.extract_with_mark_f(temporary_file, /header/)
    assert(!pacs.size.eql?(0))
    pacs.each_with_index do |pac, index|
      assert_equal(pac.parent, "header#{index}")
      assert_equal(pac.children.first, "content#{index}")
    end
  end

  def test_lines_to_hash
    file_content = "key0 value0 0\nkey1 value1 1\n"
    hash = YS1::Text.lines_to_hash(file_content)
    assert_equal(%w[key0 value0 0], hash["key0"])
    assert_equal(%w[key1 value1 1], hash["key1"])
  end

  def test_lines_to_hash_duplication
    e = assert_raises RuntimeError do
      YS1::Text.lines_to_hash("key a\nkey b")
    end
    assert_equal("Duplicate keys in lines: key", e.message)
  end

  def test_lines_to_hash_f
    file_content = "key0 value0 0\nkey1 value1 1\n"
    temporary_file = "#{@temporary_directory}/key_value.txt"
    File.write(temporary_file, file_content)

    hash = YS1::Text.lines_to_hash_f(temporary_file)
    assert_equal(%w[key0 value0 0], hash["key0"])
    assert_equal(%w[key1 value1 1], hash["key1"])
  end
end
