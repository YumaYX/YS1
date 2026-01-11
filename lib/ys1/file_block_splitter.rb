# frozen_string_literal: true

require "fileutils"
require "securerandom"
require "tmpdir"

module YS1
  # Splits a file into blocks based on a user-defined boundary condition.
  # Each block is saved to a temporary directory and can be processed sequentially.
  # Example usage of YS1::FileBlockSplitter
  #
  # @example Splitting a file into blocks and processing each
  #   processor = YS1::FileBlockSplitter.new('file.txt') do |line|
  #     line.start_with?('HEADER')
  #   end
  #
  #   # Split the file into blocks based on the block start condition
  #   processor.split_into_blocks
  #
  #   # Process each block file
  #   processor.process_blocks do |path|
  #     puts "Block file: #{path}"
  #     File.foreach(path) { |line| puts line.chomp }
  #   end
  class FileBlockSplitter
    attr_reader :file_name, :tmp_dir, :saved_files

    # Initializes a new FileBlockSplitter.
    #
    # @param file_name [String] the path to the source file
    # @yield [line] Block that determines whether a given line is a boundary.
    # @raise [ArgumentError] if no boundary block is provided
    def initialize(file_name, &boundary_block)
      raise ArgumentError, "Boundary block is required" unless block_given?

      @file_name = file_name
      @boundary_block = boundary_block
      @saved_files = []

      # Create a temporary directory with a random name
      @tmp_dir = ::File.join(Dir.tmpdir, "YS1_blocks_#{SecureRandom.hex(6)}")
      FileUtils.mkdir_p(@tmp_dir)

      # Automatically clean up on process exit
      at_exit { cleanup_tmp_dir }
    end

    # Reads the file and splits it into blocks based on the boundary block.
    # Each block is saved as a separate file in the temporary directory.
    #
    # @return [FileBlockSplitter] self
    # @raise [StandardError] re-raises any exceptions after cleaning up temporary files
    # rubocop:disable Metrics/MethodLength
    def split_into_blocks
      current_block = []
      ::File.foreach(@file_name) do |line|
        if @boundary_block.call(line) && !current_block.empty?
          save_block(current_block)
          current_block = []
        end
        current_block << line
      end
      save_block(current_block) unless current_block.empty?
      self
    rescue StandardError => e
      cleanup_tmp_dir
      raise e
    end
    # rubocop:enable Metrics/MethodLength

    # Processes each saved block file using the given block.
    # Cleans up temporary files afterward.
    #
    # @yield [file_path] gives the path of each saved block file
    def process_blocks(&)
      @saved_files.each(&)
      cleanup_tmp_dir
    end

    # Alternative method to process blocks with explicit block argument.
    #
    # @param block [Proc] the block to call with each file path
    # @raise [ArgumentError] if no block is given
    def process_blocks_with(&block)
      raise ArgumentError, "Block is required" unless block_given?

      process_blocks do |path|
        block.call(path)
      end
    end

    private

    # Saves a single block of lines to a temporary file.
    #
    # @param lines [Array<String>] lines belonging to the block
    def save_block(lines)
      return if lines.empty?

      file_path = ::File.join(@tmp_dir, "block_#{@saved_files.size}.txt")
      ::File.write(file_path, lines.join)
      @saved_files << file_path
    end

    # Deletes the temporary directory and clears the saved files list.
    def cleanup_tmp_dir
      FileUtils.rm_rf(@tmp_dir)
      @saved_files.clear
    end
  end
end
