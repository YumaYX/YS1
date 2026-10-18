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
    # Nested arrays are flattened, so `add_child(1, [2, [3]])` appends 1, 2
    # and 3.
    #
    # @param child The child objects to be added.
    def add_child(*child)
      @children.concat(child.flatten)
    end

    #
    # Retrieves an array representing the family, including the parent and children.
    #
    # @return [Array<Object>] The array representing the family.
    def family
      [@parent] + @children
    end

    # Renders the parent and children as an indented outline.
    #
    # The parent is printed first, then each child on its own line indented
    # by one level. Nested {ParentAndChild} values are rendered recursively.
    #
    # @param indent [String] the string used for one indentation level
    # @return [String] the outline without a trailing newline
    #
    # @example
    #   pac = YS1::ParentAndChild.new("Parent")
    #   pac.add_child("Child A", "Child B")
    #   puts pac.to_tree
    #   # Parent
    #   #   Child A
    #   #   Child B
    def to_tree(indent: "  ")
      [@parent.to_s, *@children.map { |child| render_child(child, indent, 1) }].join("\n")
    end

    private

    # Renders a single child at the given depth.
    #
    # @param child [Object] the child value
    # @param indent [String] one indentation level
    # @param depth [Integer] the current depth
    # @return [String]
    def render_child(child, indent, depth)
      if child.is_a?(YS1::ParentAndChild)
        child.to_tree(indent: indent).lines.map { |line| "#{indent * depth}#{line.chomp}" }.join("\n")
      else
        "#{indent * depth}#{child}"
      end
    end
  end
end
