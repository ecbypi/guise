module Guise
  class LifecycleCallback
    def initialize(guise, attribute)
      @guise = guise
      @attribute = attribute
    end

    def after_initialize(record)
      record.guises.build(@attribute => @guise)
    end

    def after_create(record)
      record.guises.create(@attribute => @guise)
    end
  end
end
