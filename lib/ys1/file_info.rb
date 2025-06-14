# frozen_string_literal: true

require "pathname"
require "digest"

module YS1
  # Represents a file with its path, name, and SHA256 digest.
  #
  # @example
  #   file_info = YS1::FileInfo.new("/path/to/file.txt")
  #   file_info.path   #=> #<Pathname:/path/to/file.txt>
  #   file_info.name   #=> "file.txt"
  #   file_info.digest #=> "a3f1c5e2..."
  class FileInfo
    # @return [Pathname] the full path of the file
    attr_reader :path

    # @return [String] the basename of the file
    attr_reader :name

    # @return [String, nil] the SHA256 digest of the file content, or nil if calculation failed
    attr_reader :digest

    # Initializes a new FileInfo instance.
    #
    # @param path [String, Pathname] the path to the file
    def initialize(path)
      @path = Pathname.new(path)
      @name = @path.basename.to_s
      @digest = calc_digest
    end

    private

    # Calculates the SHA256 digest of the file.
    #
    # @return [String, nil] SHA256 hex digest or nil if an error occurs
    def calc_digest
      Digest::SHA256.file(@path).hexdigest
    rescue StandardError => e
      warn "Failed to calculate hash: #{@path} (#{e.message})"
      nil
    end
  end
end
