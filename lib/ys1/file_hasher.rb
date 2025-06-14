# frozen_string_literal: true

require_relative "./file_info"
require "pathname"
require "digest"

module YS1
  # Processes files matching given patterns, calculates their SHA256 digests,
  # and provides summaries grouped by digest or filename.
  #
  # @example
  #   hasher = YS1::FileHasher.new(["*.rb", "lib/**/*.rb"])
  #   hasher.run_by_digest
  #   hasher.run_by_name
  class FileHasher
    # @return [Array<Hash>] array of file info hashes with keys :path, :name, :digest
    attr_reader :files

    # @return [Hash{String=>Array<String>}] mapping from filename to list of digests
    attr_reader :fn_hash

    # @return [Hash{String=>Array<String>}] mapping from digest to list of file paths
    attr_reader :kb_hash

    # Initializes the FileHasher with file path patterns.
    #
    # @param patterns [Array<String>] array of glob patterns to match files
    def initialize(patterns)
      @patterns = patterns
      @file_paths = expand_file_patterns
      @files = []
      @fn_hash = Hash.new { |h, k| h[k] = [] }  # filename => [digests]
      @kb_hash = Hash.new { |h, k| h[k] = [] }  # digest => [paths]
    end

    # Runs the processing and outputs summary grouped by digest.
    #
    # @return [void]
    def run_by_digest
      check_files_presence
      process_files
      show_digest_summary
    end

    # Runs the processing and outputs summary grouped by filename.
    #
    # @return [void]
    def run_by_name
      check_files_presence
      process_files
      show_name_summary
    end

    private

    # Expands all file patterns into a unique list of file paths.
    #
    # @return [Array<String>] unique file paths matching the patterns
    def expand_file_patterns
      @patterns.flat_map do |pat|
        Dir.glob(pat, File::FNM_EXTGLOB | File::FNM_CASEFOLD)
      end.uniq
    end

    # Checks if any files matched the patterns; exits with error if none found.
    #
    # @return [void]
    def check_files_presence
      return unless @file_paths.empty?

      puts "No files matching the specified patterns were found."
      exit 1
    end

    # Processes each file: computes digest and populates internal data structures.
    # Avoids reprocessing if files have already been processed.
    #
    # @return [void]
    def process_files
      return unless @files.empty? # Prevent duplicates on multiple runs

      @file_paths.each do |path|
        next unless File.file?(path)

        file_obj = create_file_obj(path)
        next unless file_obj[:digest]

        @files << file_obj
        @fn_hash[file_obj[:name]] << file_obj[:digest]
        @kb_hash[file_obj[:digest]] << file_obj[:path]
      end
    end

    # Creates a file info hash with path, filename, and SHA256 digest.
    #
    # @param path [String] file path
    # @return [Hash{Symbol => String, nil}] hash with keys :path, :name, :digest
    def create_file_obj(path)
      pathname = Pathname.new(path)
      digest = begin
        Digest::SHA256.file(pathname).hexdigest
      rescue StandardError => e
        warn "Failed to calculate hash: #{pathname} (#{e.message})"
        nil
      end
      { path: pathname.to_s, name: pathname.basename.to_s, digest: digest }
    end

    # Outputs a summary grouping files by identical digest.
    #
    # @return [void]
    def show_digest_summary
      warn "# Grouped by identical digest"
      @kb_hash.each do |digest, paths|
        warn "#{paths.size} #{digest}: #{paths.join(",")}"
      end
    end

    # Outputs a summary grouping files by identical filename.
    #
    # @return [void]
    def show_name_summary
      puts "# Grouped by identical filename"
      @fn_hash.each do |name, digests|
        puts "#{digests.size} #{name}: #{digests.map { |h| h[0,7] }.join(",")}"
      end
    end
  end
end
