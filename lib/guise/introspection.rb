require 'active_support/concern'

module Guise
  module Introspection
    extend ActiveSupport::Concern

    def has_guise?(value)
      value = value.to_s.classify

      unless guise_options[:names].any? { |name| name == value }
        raise ArgumentError, "no such guise #{value}"
      end

      guises.any? { |guise| !guise.marked_for_destruction? && guise[guise_options[:attribute]] == value }
    end

    def has_any_guises?(*values)
      values.any? { |value| has_guise?(value) }
    end

    def has_guises?(*values)
      values.all? { |value| has_guise?(value) }
    end

    private

    def guise_options
      Guise.registry[self.class.table_name.classify]
    end
  end
end
