module Guise
  class DefinitionNotFound < StandardError
    def initialize(name)
      @name = name
    end

    def message
      "no guises defined for #{@name.inspect}"
    end
  end

  class DuplicateDefinition < StandardError
    def initialize(name)
      @name = name
    end

    def message
      "guise definition for #{@name.inspect} already exists"
    end
  end

  class InvalidGuiseValue < ArgumentError
    def initialize(guise_value, klass)
      @guise_value = guise_value
      @klass = klass
    end

    def message
      "`#{guise_value}' is not a defined guise value for #{klass}"
    end
  end
end
