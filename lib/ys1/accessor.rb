# frozen_string_literal: true

module YS1
  #
  # Dynamic attribute accessor backed by a Hash.
  #
  # Include it into a class (or extend an object) to get getter/setter access
  # for attributes that are not defined ahead of time. Values are stored in a
  # per-instance Hash, so each instance keeps its own attributes.
  #
  # This replaces the former +DynamicObject+ and +LazyAccessor+ modules with a
  # single, simpler implementation.
  #
  # @example Include into a class
  #   class User
  #     include YS1::Accessor
  #   end
  #
  #   user = User.new
  #
  #   user.name = "Taro"
  #   user.age = 20
  #
  #   user.name
  #   # => "Taro"
  #
  #   user.age
  #   # => 20
  #
  # @example Extend a single object
  #   obj = Object.new
  #   obj.extend(YS1::Accessor)
  #
  #   obj.title = "Hello"
  #
  #   obj.title
  #   # => "Hello"
  #
  # @note Reading an attribute that has not been set raises +NoMethodError+.
  #
  module Accessor
    #
    # Internal storage Hash of attributes.
    #
    # @return [Hash]
    #
    def data
      @data ||= {}
    end

    #
    # Dynamically handles getter and setter methods.
    #
    # Setters store the value into {#data}; getters return it. An unknown
    # getter falls through to +method_missing+ (raising +NoMethodError+).
    #
    # @param name [Symbol]
    #   Method name
    #
    # @param args [Array]
    #   Method arguments
    #
    # @return [Object]
    #
    # @raise [NoMethodError]
    #   Raised when an unknown getter is called
    #
    def method_missing(name, *args)
      str = name.to_s
      return super unless str.end_with?("=") || data.key?(name)

      key = str.delete_suffix("=").to_sym
      data[key] = args.first if str.end_with?("=")
      data[key]
    end

    #
    # Checks whether a dynamic method is supported.
    #
    # Every setter is reported as available; getters are available once the
    # attribute has been assigned.
    #
    # @param name [Symbol]
    #   Method name
    #
    # @param include_private [Boolean]
    #   Whether to include private methods
    #
    # @return [Boolean]
    #
    def respond_to_missing?(name, include_private = false)
      name.to_s.end_with?("=") || data.key?(name) || super
    end
  end
end
