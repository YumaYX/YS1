# frozen_string_literal: true

module Ys1
  # Represents a parent and its children in a family structure.
  class ParentAndChild
    # @return [Object] The parent object.
    attr_reader :parent

    # @return [Array<Object>] The array of child objects.
    attr_accessor :children

    # Initializes a new instance of ParentAndChild.
    #
    # @param parent [Object] The parent object.
    def initialize(parent)
      @parent   = parent
      @children = []
    end

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

    # Retrieves an array representing the family, including the parent and children.
    #
    # @return [Array<Object>] The array representing the family.
    def family
      [@parent] + @children
    end
  end
end
