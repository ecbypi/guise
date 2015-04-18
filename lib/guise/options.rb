module Guise
  # @api private
  class Options
    attr_reader(
      :source_class,
      :values,
      :association_name,
      :association_name_singular,
      :attribute,
      :association_options,
      :scopes
    )

    attr_writer :association_class

    def initialize(source_class, *values)
      options = values.extract_options!

      if values.empty?
        raise ArgumentError, "must specify values in `has_guises`"
      end

      @source_class = source_class
      @values = values.map(&:to_s).to_set
      @association_name =
        options.delete(:association) || DEFAULT_ASSOCIATION_NAME
      @association_name_singular = @association_name.to_s.singularize
      @attribute = options.delete(:attribute) || DEFAULT_ATTRIBUTE_NAME
      @association_options = options.reverse_merge!(default_association_options)

      @scopes = values.inject(HashWithIndifferentAccess.new) do |all, value|
        all.merge!(value => {})
      end
      @scopes.freeze
    end

    def scope(guise_value, scope_type)
      value_scopes = @scopes.fetch(guise_value) do
        raise InvalidGuiseValue.new(guise_value, source_class)
      end

      value_scopes.fetch(scope_type) do
        raise ArgumentError, "`#{scope_type}' is not a valid type of scope"
      end
    end

    def register_scope(guise_value, scope)
      value_scopes = @scopes.fetch(guise_value) do
        raise InvalidGuiseValue.new(guise_value, source_class)
      end

      if value_scopes.key?(scope.type)
        raise "`#{scope.type}' scope already defined for #{source_class}"
      end

      value_scopes[scope.type] = scope
    end

    def association_class
      if defined?(@association_class)
        @association_class
      else
        raise "`guise_for` was not called on the association class"
      end
    end

    def source_association_name
      source_class.model_name.singular.to_sym
    end

    def default_association_options
      { foreign_key: "#{source_association_name}_id" }
    end
  end
end
