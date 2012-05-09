module Guise
  module Introspection

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def introspect_guises(names)
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

    def has_role?(name)
      name = name.to_s.classify

      if !self.class.guises.include?(name)
        raise NameError, "no such guise #{name}"
      end

      guises.pluck(guise_attribute).include?(name)
    end

    def has_any_roles?(*names)
      names.map(&method(:has_role?)).any?
    end

    def has_roles?(*names)
      names.map(&method(:has_role?)).all?
    end

    protected

    def guise_attribute
      self.class.guise_attribute
    end

    def guise_table
      self.class.guise_table
    end
  end
end
