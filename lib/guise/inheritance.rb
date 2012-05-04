module Guise
  module Inheritance
    def build_guises
      guises.each do |name|
        scope_name = name.tableize.to_sym
        introspective_name = "#{name.underscore}?"

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

        # define the introspection method for the type
        class_eval <<-METHOD, __FILE__, __LINE__ + 1
          def #{introspective_name}
            has_role?(#{name})
          end
        METHOD
      end
    end
  end
end
