# frozen_string_literal: true

module YS1
  # Join
  module Join
    def self.cross(*arrays, &)
      return enum_for(__method__, *arrays) unless block_given?

      if arrays.empty?
        yield []
        return
      end

      arrays.reduce([[]]) do |acc, arr|
        acc.product(arr).map { |prefix, item| prefix + [item] }
      end.each(&)
    end

    def self.cross_from_files(*filenames, &)
      arrays = filenames.map do |filename|
        File.readlines(filename, chomp: true)
      end

      cross(*arrays, &)
    end
  end
end
