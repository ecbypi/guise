module Guise
  module Attributes
    def set_attributes(names, options)
      @@guise_attributes = options.reverse_merge(
        :association => :guises,
        :attribute => :title,
        :names => names
      )

      class_eval do
        alias_method :guises, guise_association
      end if guise_association != :guises
    end

    def guises
      @@guise_attributes[:names]
    end

    def guise_association
      @@guise_attributes[:association]
    end

    def guise_attribute
      @@guise_attributes[:attribute]
    end
  end
end
