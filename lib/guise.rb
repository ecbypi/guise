require 'guise/version'
require 'guise/options'
require 'guise/introspection'

module Guise

  def has_guises(*names)
    extend Options

    options = names.last.is_a?(Hash) ? names.pop : {}
    class_names = names.map(&:to_s).map(&:classify)

    guise_options, association_options = extract_guise_options(class_names, options)

    build_guises(class_names, guise_options)
    introspect_guises(class_names)

    has_many guise_association, association_options

    if guise_association != :guises
      alias_method :guises, guise_association
    end
  end

  def guise_for(name, options = {})
    association = Object.const_get(name.to_s.classify)
    foreign_key = options[:foreign_key] || "#{association.name.underscore}_id"

    belongs_to name, options

    if options[:validate] != false
      validates association.guise_attribute,
                :uniqueness => { :scope => foreign_key },
                :presence => true,
                :inclusion => { :in => association.guises }
    end
  end

  private

  def build_guises(names, options)
    names.each do |name|
      scope_name = name.tableize.to_sym

      # Add a scope for this type of resource
      scope scope_name, joins(guise_association).where(guise_association => { guise_attribute => name })

      # build the class setting it's default scope to limit to those of itself
      guise_class = Class.new(self) do
        default_scope { send(scope_name) }

        after_initialize do
          self.guises.new(self.guise_attribute => name) unless self.has_role?(name)
        end

        after_create do
          self.guises.create(self.guise_attribute => name)
        end
      end

      Object.const_set(name, guise_class)
    end
  end

  def introspect_guises(names)
    include Introspection

    names.each do |name|
      method_name = "#{name.underscore}?"
      define_method method_name do
        has_role?(name)
      end
    end
  end
end

ActiveRecord::Base.extend Guise
