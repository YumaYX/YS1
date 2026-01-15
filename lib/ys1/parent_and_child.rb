# frozen_string_literal: true

module YS1
  # Represents a parent and its children in a family structure.
  class ParentAndChild
    # @return [Object] The parent object.
    attr_reader :parent

    # @return [Array<Object>] The array of child objects.
    attr_accessor :children

    #
    # Initializes a new instance of ParentAndChild.
    #
    # @param parent [Object] The parent object.
    def initialize(parent)
      @parent   = parent
      @children = []
    end

    #
    # Adds child objects to the array of children.
    #
    # @param child The child objects to be added.
    def add_child(*child)
      child.each do |element|
        if element.respond_to?(:to_ary)
          add_child(*element.to_ary)
        else
          @children << element
        end
      end
    end

    #
    # Retrieves an array representing the family, including the parent and children.
    #
    # @return [Array<Object>] The array representing the family.
    def family
      [@parent] + @children
    end
  end
end

# OpenClass String
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
