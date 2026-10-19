# frozen_string_literal: true

module YS1
  #
  # Lazy singleton attr_accessor.
  #
  # Getter/setter methods are generated
  # on first access via method_missing.
  #
  # Values are stored in instance variables.
  #
  # @example
  #   obj = Object.new
  #
  #   obj.extend(YS1::LazyAccessor)
  #
  #   obj.name = "Taro"
  #   obj.age = 20
  #
  #   p obj.name
  #   # => "Taro"
  #
  #   p obj.age
  #   # => 20
  #
  module LazyAccessor
    #
    # Dynamically defines getter/setter methods.
    #
    # @param name [Symbol]
    #   Method name
    #
    # @param args [Array]
    #   Method arguments
    #
    # @return [Object]
    #
    def method_missing(name, *args)
      attr_name, ivar_name = parse_name(name)
      define_accessors(attr_name, ivar_name)

      if name.to_s.end_with?("=")
        public_send(name, args.first)
      elsif instance_variable_defined?(ivar_name)
        public_send(name)
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
      str       = name.to_s
      setter    = str.end_with?("=")
      attr_name = str.delete_suffix("=")
      ivar_name = :"@#{attr_name}"

      return true if setter

      instance_variable_defined?(ivar_name) || super
    end

    private

    # Parses a method name into attribute and instance variable names.
    #
    # @param name [Symbol] method name
    # @return [Array<Symbol, Symbol>] attribute name and ivar name
    def parse_name(name)
      attr_name = name.to_s.delete_suffix("=").to_sym
      [attr_name, :"@#{attr_name}"]
    end

    # Defines singleton getter and setter methods for the given attribute.
    #
    # @param attr_name [Symbol] attribute name
    # @param ivar_name [Symbol] instance variable name
    def define_accessors(attr_name, ivar_name)
      define_singleton_method(attr_name) do
        instance_variable_get(ivar_name)
      end

      define_singleton_method("#{attr_name}=") do |value|
        instance_variable_set(ivar_name, value)
      end
    end
  end
end
