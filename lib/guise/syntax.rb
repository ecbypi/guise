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
      join_table  = options[:table_name] || association

      Guise.registry[self.name] = {
        names: guises,
        association: association,
        attribute: attribute
      }

      guises.each do |guise|
        method_name = guise.underscore
        scope method_name.pluralize, -> { select("#{self.table_name}.*").joins(association).where(join_table => { attribute => guise }) }

        define_method "#{method_name}?" do
          has_guise?(guise)
        end
      end

      has_many association, options.except(:association, :attribute, :table_name)

      if association != :guises
        association_singular = association.to_s.singularize

        alias_method :guises, association
        alias_method :guises=, "#{association}="
        alias_method :guise_ids, "#{association_singular}_ids"
        alias_method :guise_ids=, "#{association_singular}_ids="
        alias_method "has_#{association_singular}?", :has_guise?
        alias_method "has_#{association}?", :has_guises?
        alias_method "has_any_#{association}?", :has_any_guises?
      end
    end

    def guise_of(class_name)
      options = Guise.registry[class_name]

      if options.nil?
        raise ArgumentError, "no guises defined on #{class_name}"
      end

      default_scope -> { send(model_name.plural) }

      after_initialize SourceCallback.new(self.name, options[:attribute])
    end

    def guise_for(class_name, options = {})
      guise_options = Guise.registry[class_name]

      if guise_options.nil?
        raise ArgumentError, "no guises defined on #{class_name}"
      end

      association = class_name.to_s.underscore.to_sym
      guises      = guise_options[:names]
      attribute   = guise_options[:attribute]
      foreign_key = options[:foreign_key] || "#{class_name.to_s.underscore}_id"

      belongs_to association, options.except(:validate)

      guises.each do |guise|
        scope guise.underscore.pluralize, -> { where(attribute => guise) }
      end

      if options[:validate] != false
        validates attribute, uniqueness: { scope: foreign_key }, presence: true, inclusion: { in: guises }
      end
    end

    def scoped_guise_for(class_name)
      guise_options = Guise.registry[class_name]

      if guise_options.nil?
        raise ArgumentError, "no guises defined on #{class_name}"
      end

      attribute = guise_options[:attribute]
      parent_name = table_name.classify

      value = guise_options[:names].detect do |guise|
        guise == model_name.to_s.chomp(parent_name)
      end

      default_scope -> { where(attribute => value) }

      after_initialize AssociationCallback.new(value, attribute)
    end
  end
end
