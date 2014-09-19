require 'active_support/core_ext/string/inflection'

module Guise
  # {Introspection} handles checking if a record has one or more `guise` records
  # associated with it.
  module Introspection
    # Checks if the record has a `guise` record identified by on the specified
    # `value`.
    #
    # @param [String, Class, Symbol] value `guise` to check
    # @return [true, false]
    def has_guise?(value)
      value = value.to_s.classify

      unless guise_options[:names].any? { |name| name == value }
        raise ArgumentError, "no such guise #{value}"
      end

      guises.any? { |guise| !guise.marked_for_destruction? && guise[guise_options[:attribute]] == value }
    end

    # Checks if the record has any `guise` records with identified by any of
    # the specified `values`.
    #
    # @param [Array<String, Class, Symbol>] value `guise` to check
    # @return [true, false]
    def has_any_guises?(*values)
      values.any? { |value| has_guise?(value) }
    end

    # Checks if the record has `guise` records for all of the specified
    # `values`.
    #
    # @param [Array<String, Class, Symbol>] value `guise` to check
    # @return [true, false]
    def has_guises?(*values)
      values.all? { |value| has_guise?(value) }
    end

    private

    def guise_options
      Guise.registry[self.class.table_name.classify]
    end
  end
end
