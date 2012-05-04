module Guise
  module Attributes
    def set_attributes(names, options)
      @@guise_attributes = options.reverse_merge(
        :as => :guises,
        :attribute => :title,
        :names => names
      )

      class_eval do
        alias_method :guises, guise_table
      end
    end

    def guises
      @@guise_attributes[:names]
    end

    def guise_table
      @@guise_attributes[:as]
    end

    def guise_attribute
      @@guise_attributes[:attribute]
    end
  end
end
