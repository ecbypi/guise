module Guise
  class Callback
    def initialize(guise, attribute)
      @guise = guise
      @attribute = attribute
    end
  end

  class SourceCallback < Callback
    def after_initialize(record)
      record.guises.build(@attribute => @guise)
    end

    def after_create(record)
      record.guises.create(@attribute => @guise)
    end
  end

  class AssociationCallback < Callback
    def after_initialize(record)
      record.assign_attributes(@attribute => @guise)
    end

    def before_create(record)
      record.assign_attributes(@attribute => @guise)
    end
  end
end
