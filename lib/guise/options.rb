module Guise
  module Options
    def set_guise_options(names, options)
      @@guise_options = options.reverse_merge(
        :association => :guises,
        :attribute => :title,
        :names => names
      )

      class_eval do
        alias_method :guises, guise_association
      end if guise_association != :guises

      @@guise_options
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
