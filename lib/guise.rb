require "active_support/core_ext/string/inflections"
require "active_support/core_ext/array/extract_options"
require 'active_support/core_ext/module/attribute_accessors'
require "active_support/lazy_load_hooks"

require 'guise/version'
require "guise/errors"
require "guise/registry"
require "guise/options"
require "guise/builders"
require "guise/scopes"
require 'guise/callbacks'
require "guise/introspection"
require "guise/syntax"

module Guise
  mattr_reader :registry
  @@registry = Registry.new

  DEFAULT_ASSOCIATION_NAME = "guises"
  DEFAULT_ATTRIBUTE_NAME = "value"

  def self.register_source(source_class, *guises)
    options = Options.new(source_class, *guises)
    registry[source_class.name] = options

    HasGuisesBuilder.new(options).build!
  end

  def self.register_association(association_class, source_class_name, association_options)
    options = registry[source_class_name]

    GuiseForBuilder.new(association_class, options, association_options).build!
  end
end

ActiveSupport.on_load(:active_record) do
  extend Guise::Syntax
end
