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
      if @registry.key?(name)
        raise DuplicateDefinition.new(name)
      end

      @registry[name] = definition
    end
  end
end
