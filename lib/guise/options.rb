module Guise
  module Options
    def extract_guise_options(names, options)
      @@guise_options = {
        :association => options.delete(:association) || :guises,
        :attribute   => options.delete(:attribute)   || :title,
        :names       => names
      }

      return @@guise_options, options
    end

    def guises
      @@guise_options[:names]
    end

    def guise_association
      @@guise_options[:association]
    end

    def guise_attribute
      @@guise_options[:attribute]
    end
  end
end
