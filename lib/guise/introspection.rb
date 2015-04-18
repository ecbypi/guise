require "active_support/core_ext/string/inflections"

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

      unless guise_options.values.include?(value)
        raise ArgumentError, "no such guise #{value}"
      end

      association(guise_options.association_name).reader.any? do |record|
        !record.marked_for_destruction? &&
          record[guise_options.attribute] == value
      end
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
  end
end
