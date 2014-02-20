module Guise
  class LifecycleCallback
    def initialize(guise)
      @guise = guise
    end

    def after_initialize(record)
      attribute = guise_attribute_for(record)
      record.guises.build(attribute => @guise)
    end

    def after_create(record)
      attribute = guise_attribute_for(record)
      record.guises.create(attribute => @guise)
    end

    private

    def guise_attribute_for(record)
      record.guise_options[:attribute]
    end
  end
end
