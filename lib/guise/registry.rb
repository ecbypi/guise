require "active_support/hash_with_indifferent_access"

module Guise
  class Registry
    def initialize
      @registry = HashWithIndifferentAccess.new
    end

    def [](name)
      @registry.fetch(name) do
        raise DefinitionNotFound.new(name)
      end
    end

    def []=(name, definition)
      @registry[name] = definition
    end
  end
end
