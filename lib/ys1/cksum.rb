# frozen_string_literal: true

# YS1
module YS1
  # Cksum class calculates and stores checksums from a file.
  class Cksum
    # @return [Hash] the calculated checksums
    attr_reader :sums

    # Initializes a new Cksum object.
    #
    # @param [String] file_name the name of the file to read checksums from
    def initialize(file_name)
      @file_name = file_name
      @sums = {}
    end

    # Processes the file and stores the checksums.
    #
    # @param [String] prefix the prefix to add to the file names (default is "")
    # @return [Hash] the calculated checksums
    def hashnize(prefix = "")
      File.foreach(@file_name) do |line|
        line.chomp!
        parts = line.match(/^(\d+)\s+\d+\s+(.*)$/)
        # example: 523877570 1512 ys1.gemspec

        sum_value = parts[1]
        file_name = prefix + parts[2].gsub(%r{^\./}, "")
        @sums.store(file_name, sum_value)
      end
      @sums
    end

    # Compares the sums of files with another Cksum object and returns the file names
    # that exist in both objects but have different sums.
    #
    # @param another [Cksum] The other Cksum object to compare with.
    # @return [Array<String>] An array of file names that have different sums in the two objects.
    def compare(another)
      @sums.keys.select do |file_name|
        another.sums.key?(file_name) && (@sums[file_name] != another.sums[file_name])
      end
    end
  end
end
