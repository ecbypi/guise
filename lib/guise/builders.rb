require "guise/scopes"

module Guise
  # @api private
  class HasGuisesBuilder
    def initialize(options)
      @options = options
    end

    def build!
      set_guise_options!
      define_association!
      define_scopes!

      if options.association_options != DEFAULT_ASSOCIATION_NAME
        define_association_aliases!
      end

      define_introspection_aliases!
    end

    private

    attr_reader :options

    def set_guise_options!
      source_class.class_attribute :guise_options, instance_writer: false
      source_class.guise_options = options
    end

    def define_association!
      source_class.has_many(
        options.association_name,
        options.association_options
      )
    end

    def define_scopes!
      options.values.each do |value|
        method_name = value.underscore
        scope_name = method_name.pluralize

        source_class.scope scope_name, HasGuisesScope.new(value, options)

        source_class.class_eval <<-METHOD
          def #{method_name}?
            has_guise?(#{value})
          end
        METHOD
      end
    end

    def define_association_aliases!
      source_class.class_eval <<-ASSOCIATION_ALIASES
        alias_method :guises, :#{association_name}
        alias_method :guises=, :#{association_name}=
        alias_method :guise_ids, :#{association_name_singular}_ids
        alias_method :guise_ids=, :#{association_name_singular}_ids=
      ASSOCIATION_ALIASES
    end

    def define_introspection_aliases!
      source_class.class_eval <<-INTROSPECTION_ALIASES
        alias_method :has_#{association_name_singular}?, :has_guise?
        alias_method :has_#{association_name}?, :has_guises?
        alias_method :has_any_#{association_name}?, :has_any_guises?
      INTROSPECTION_ALIASES
    end

    def source_class
      options.source_class
    end

    def association_name
      options.association_name
    end

    def association_name_singular
      options.association_name_singular
    end
  end

  # @api private
  class GuiseForBuilder
    def initialize(association_class, options, association_options)
      @association_class = association_class
      @options = options
      @association_options = association_options.reverse_merge!(
        @options.default_association_options
      )
      @define_validations = !@association_options.delete(:validate)
    end

    def build!
      update_guise_options!
      define_association!
      define_scopes!

      if define_validations?
        define_validations!
      end
    end

    private

    attr_reader(
      :association_class,
      :options,
      :association_options,
      :define_validations
    )

    alias :define_validations? :define_validations

    def update_guise_options!
      options.association_class = association_class
    end

    def define_association!
      association_class.belongs_to(
        options.source_association_name,
        association_options
      )
    end

    def define_scopes!
      options.values.each do |value|
        association_class.scope(
          value.underscore.pluralize,
          GuiseForScope.new(value, options)
        )
      end
    end

    def define_validations!
      association_class.validates(
        options.attribute,
        uniqueness: { scope: options.association_options[:foreign_key] },
        presence: true,
        inclusion: { in: options.values }
      )
    end
  end
end
