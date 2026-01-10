# frozen_string_literal: true

require_relative "parent_and_child"

#
# Extends the String class to convert a multiline string into
# parent–child structures based on a matching start line.
#
class String
  #
  # Parses the string line by line and builds parent–child relationships.
  #
  # Lines matching `start_line` are treated as parents.
  # Subsequent lines are added as children to the most recent parent.
  #
  # @param start_line [Regexp]
  #   A regular expression used to identify parent lines.
  #
  # @param parents [Array<YS1::ParentAndChild>]
  #   An array used to accumulate generated parent–child objects.
  #
  # @return [Array<YS1::ParentAndChild>]
  #   An array of ParentAndChild objects with their associated children.
  #
  # @example Basic usage
  #   text = <<~TEXT
  #     PARENT A
  #       child1
  #       child2
  #     PARENT B
  #       child3
  #   TEXT
  #
  #   text.to_pacs(/^PARENT/)
  #
  def to_pacs(start_line, parents = [])
    each_line do |raw_line|
      line = raw_line.chomp

      if line.match?(start_line)
        parents << YS1::ParentAndChild.new(line)
        next
      end

      parents.last&.add_child(line)
    end

    parents
  end
end
