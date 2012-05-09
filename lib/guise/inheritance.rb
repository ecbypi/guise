module Guise
  module Inheritance
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
  end
end
