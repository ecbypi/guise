require 'active_support/concern'
require 'active_support/core_ext/hash/keys'
require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/string/inflections'

module Guise
  module Syntax
    def has_guises(*guises)
      include Introspection

      options = guises.last.is_a?(Hash) ? guises.pop : {}

      guises      = guises.map(&:to_s)
      association = options.fetch(:association)
      attribute   = options.fetch(:attribute)

      Guise.registry[self.name] = {
        names: guises,
        association: association,
        attribute: attribute
      }

      guises.each do |guise|
        method_name = guise.underscore
        scope method_name.pluralize, -> { joins(association).where(association => { attribute => guise }) }

        define_method "#{method_name}?" do
          has_guise?(guise)
        end
      end

      has_many association, options.except(:association, :attribute)

      if association != :guises
        association_singular = association.to_s.singularize

        alias_method :guises, association
        alias_method "has_#{association_singular}?", :has_guise?
        alias_method "has_#{association}?", :has_guises?
        alias_method "has_any_#{association}?", :has_any_guises?
      end
    end

    def guise_of(name)
      options = Guise.registry[name]

      if options.nil?
        raise ArgumentError, "no guises defined on #{name}"
      end

      default_scope -> { send(model_name.plural) }

      callback = LifecycleCallback.new(self.name, options[:attribute])

      after_initialize callback
      after_create callback
    end

    def guise_for(name, options = {})
      guise_options = Guise.registry[name]

      if guise_options.nil?
        raise ArgumentError, "no guises defined on #{name}"
      end

      association = name.to_s.underscore.to_sym
      guises      = guise_options[:names]
      attribute   = guise_options[:attribute]
      foreign_key = options[:foreign_key] || "#{name.underscore}_id"

      belongs_to association, options.except(:validate)

      guises.each do |guise|
        scope guise.underscore.pluralize, -> { where(attribute => guise) }
      end

      if options[:validate] != false
        validates attribute, uniqueness: { scope: foreign_key }, presence: true, inclusion: { in: guises }
      end
    end
  end
end
