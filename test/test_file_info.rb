# frozen_string_literal: true

require_relative "helper"

class TestYS1FileInfo < Minitest::Test
  def setup
    # Create a temporary directory for each test method
    @temp_dir = Dir.mktmpdir
    @temp_file_content = "This is some test content for mktmpdir."
    @temp_file_name = File.join(@temp_dir, "test_file_mktmpdir.txt")
    File.write(@temp_file_name, @temp_file_content)

    # Calculate the expected SHA256 digest
    @expected_digest = Digest::SHA256.hexdigest(@temp_file_content)
  end

  def teardown
    # Ensure the temporary directory and its contents are removed
    FileUtils.remove_entry @temp_dir if File.exist?(@temp_dir)
  end

  def test_initialize_with_valid_path
    file_info = YS1::FileInfo.new(@temp_file_name)
    assert_instance_of Pathname, file_info.path
    assert_equal "test_file_mktmpdir.txt", file_info.name # Assert on the basename
    assert_equal @expected_digest, file_info.digest
  end

  #   def test_initialize_with_non_existent_path
  #     non_existent_path = File.join(@temp_dir, "non_existent_file.txt")
  #     file_info = YS1::FileInfo.new(non_existent_path)
  #     assert_instance_of Pathname, file_info.path
  #     assert_equal "non_existent_file.txt", file_info.name
  #     assert_nil file_info.digest # Expect digest to be nil for non-existent file
  #   end
  #
  #   def test_digest_calculation_failure
  #     # Stub the Digest::SHA256.file method to raise an error
  #     Digest::SHA256.stub :file, ->(_) { raise StandardError, "Simulated error" } do
  #       file_info = YS1::FileInfo.new(@temp_file_name)
  #       assert_nil file_info.digest
  #     end
  #   end
end
