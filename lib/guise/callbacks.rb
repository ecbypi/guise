module Guise
  class Callback
    def initialize(guise, attribute)
      @guise = guise
      @attribute = attribute
    end
  end

  class SourceCallback < Callback
    def after_initialize(record)
      if record.new_record?
        record.guises.build(@attribute => @guise)
      end
    end
  end

  class AssociationCallback < Callback
    def after_initialize(record)
      record.assign_attributes(@attribute => @guise)
    end
  end
end
