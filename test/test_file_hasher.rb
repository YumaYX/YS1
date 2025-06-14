# frozen_string_literal: true

require_relative "helper"

class TestYS1FileHasher < Minitest::Test
  def setup
    @tmpdir = Dir.mktmpdir
    # Create sample files
    @file1 = File.join(@tmpdir, "file1.txt")
    @file2 = File.join(@tmpdir, "file2.txt")
    @file3 = File.join(@tmpdir, "file3.txt")

    File.write(@file1, "hello world")
    File.write(@file2, "hello world") # same content as file1 (same digest)
    File.write(@file3, "different content")
  end

  def teardown
    FileUtils.rm_rf(@tmpdir)
  end

  def test_expand_file_patterns
    hasher = YS1::FileHasher.new(["#{@tmpdir}/*.txt"])
    paths = hasher.send(:expand_file_patterns)
    assert_includes paths, @file1
    assert_includes paths, @file2
    assert_includes paths, @file3
  end

  def test_process_files_and_hash_groups
    hasher = YS1::FileHasher.new(["#{@tmpdir}/*.txt"])
    hasher.send(:process_files)

    # common
    # files array should contain 3 entries
    assert_equal(3, hasher.files.size)

    # fn_hash keys include all filenames
    assert_equal ["file1.txt", "file2.txt", "file3.txt"].sort, hasher.fn_hash.keys.sort

    # kb_hash keys include 2 unique digests (file1 & file2 have same digest)
    assert_equal 2, hasher.kb_hash.keys.size

    # file1.txt and file2.txt share same digest
    digest_file1 = hasher.fn_hash["file1.txt"].first
    digest_file2 = hasher.fn_hash["file2.txt"].first
    assert_equal(digest_file1, digest_file2)

    # file3.txt digest is unique
    digest_file3 = hasher.fn_hash["file3.txt"].first
    refute_equal(digest_file1, digest_file3)
  end

  #   def test_check_files_presence_exits_if_no_files
  #     hasher = YS1::FileHasher.new(["nonexistent/*.nope"])
  #     # forcibly clear file_paths to simulate no matches
  #     hasher.instance_variable_set(:@file_paths, [])
  #     assert_raises SystemExit do
  #       hasher.send(:check_files_presence)
  #     end
  #   end
end
