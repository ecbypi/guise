module Guise
  module Introspection

    def has_role?(name)
      name = name.to_s.classify

      if !self.class.guises.include?(name)
        raise NameError, "no such guise #{name}"
      end

      guises.map(&guise_attribute).include?(name)
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
