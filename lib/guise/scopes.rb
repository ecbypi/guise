module Guise
  # @api private
  class Scope
    def initialize(value, options)
      @value = value
      @options = options

      @options.register_scope(@value, self)
    end
  end

  # @api private
  class HasGuisesScope < Scope
    def call
      relation.create_with(association_name => [association_relation.new])
    end

    def type
      :has_guises
    end

    private

    def relation
      source_class.
        select(source_class.arel_table[Arel.star]).
        joins(association_name).
        merge(association_relation)
    end

    def source_class
      @options.source_class
    end

    def association_name
      @options.association_name
    end

    def association_relation
      @options.scope(@value, :guise_for).call
    end
  end

  # @api private
  class GuiseOfScope < HasGuisesScope
    def call
      relation
    end

    def type
      :guise_of
    end
  end

  # @api private
  class GuiseForScope < Scope
    def call
      @options.association_class.where(@options.attribute => @value)
    end

    def type
      :guise_for
    end
  end
end
