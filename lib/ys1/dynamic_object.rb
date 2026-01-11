# frozen_string_literal: true

module YS1
  #
  # Dynamic attribute accessor using Hash storage.
  #
  # This module allows dynamic getter/setter access like:
  #
  #   obj.name = "Taro"
  #   obj.name
  #
  # Internally, values are stored in a Hash.
  #
  # @example Include into a class
  #   class User
  #     include YS1::DynamicObject
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
  #   obj.extend(YS1::DynamicObject)
  #
  #   obj.title = "Hello"
  #
  #   obj.title
  #   # => "Hello"
  #
  module DynamicObject
    #
    # Internal storage Hash.
    #
    # @return [Hash]
    #
    def data
      @data ||= {}
    end

    #
    # Dynamically handles getter/setter methods.
    #
    # Setter methods store values into {#data}.
    # Getter methods retrieve values from {#data}.
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
    #   Raised when unknown getter is called
    #
    def method_missing(name, *args)
      str = name.to_s
      key = str.chomp("=").to_sym

      if str.end_with?("=")
        data[key] = args.first
      elsif data.key?(name.to_sym)
        data[name.to_sym]
      else
        super
      end
    end

    #
    # Checks whether dynamic methods are supported.
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
      str = name.to_s

      str.end_with?("=") ||
        data.key?(name.to_sym) ||
        super
    end
  end
end
