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
    # rubocop:disable Metrics/MethodLength

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
      str        = name.to_s
      setter     = str.end_with?("=")
      attr_name  = str.delete_suffix("=").to_sym
      ivar_name  = :"@#{attr_name}"

      #
      # define getter
      #
      define_singleton_method(attr_name) do
        instance_variable_get(ivar_name)
      end

      #
      # define setter
      #
      define_singleton_method("#{attr_name}=") do |value|
        instance_variable_set(ivar_name, value)
      end

      if setter
        public_send(name, args.first)
      elsif instance_variable_defined?(ivar_name)
        public_send(name)
      else
        super
      end
    end
    # rubocop:enable Metrics/MethodLength

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
  end
end
