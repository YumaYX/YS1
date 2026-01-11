# frozen_string_literal: true

require_relative "parent_and_child"

# Extends the core String class
class String
  # Converts the string into an array of YS1::ParentAndChild objects.
  #
  # Each line that matches the `start_line` pattern becomes a new parent object.
  # Subsequent lines are added as children to the most recent parent object.
  #
  # @param start_line [Regexp] The regular expression to identify the start of a parent block.
  # @return [Array<YS1::ParentAndChild>] Array of parent objects with nested children.
  #
  # @example Basic usage
  #   content = <<~DATA
  #     Parent 1
  #     Child 1
  #     Child 2
  #     Parent 2
  #     Child 3
  #   DATA
  #
  #   parents = content.to_pacs(/^Parent/)
  #   parents.each do |parent|
  #     puts parent.line
  #     parent.children.each { |child| puts "  #{child}" }
  #   end
  #
  # @note For very large data, consider splitting the file using the `csplit` command
  #   before processing to avoid loading the entire file into memory at once.
  def to_pacs(start_line)
    each_line.with_object([]) do |raw_line, pacs|
      line = raw_line.chomp

      if line.match?(start_line)
        pacs << YS1::ParentAndChild.new(line)
      else
        pacs.last&.add_child(line)
      end
    end
  end
end
