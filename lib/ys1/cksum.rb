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

        sum_value = parts[1].to_i
        file_name = prefix + parts[2].gsub(%r{^\./}, "")
        @sums[file_name] = sum_value
      end
      @sums
    end

    # Compares the current checksums with another Cksum object and extracts the differences.
    #
    # @param [Cksum] another another Cksum object to compare against
    # @return [Array<String>] the list of files with different checksums
    def compare(another)
      diff = []
      another.sums.each do |target_file_name, fsum|
        diff << target_file_name if @sums.key?(target_file_name) && fsum != @sums[target_file_name]
      end
      diff
    end
  end
end
