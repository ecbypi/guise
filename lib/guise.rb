require 'guise/version'
require 'guise/options'
require 'guise/introspection'

module Guise

  def has_guises(*names)
    extend Options

    options = names.last.is_a?(Hash) ? names.pop : {}
    class_names = names.map(&:to_s).map(&:classify)

    guise_options = set_guise_options(class_names, options)

    build_guises(class_names, guise_options)
    introspect_guises(class_names)
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

    introspective_names = names.map { |name| "#{name.underscore}?" }

    introspective_names.each do |method_name|
      class_eval <<-METHOD, __FILE__, __LINE__ + 1
        def #{method_name}
          has_role?(#{name})
        end
      METHOD
    end
  end
end

ActiveRecord::Base.extend Guise
