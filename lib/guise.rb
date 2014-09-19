require 'active_support/core_ext/module/attribute_accessors'
require 'active_support/hash_with_indifferent_access'

require 'guise/version'
require 'guise/callbacks'
require 'guise/syntax'
require 'guise/introspection'

module Guise
  mattr_reader :registry
  @@registry = HashWithIndifferentAccess.new
end

if defined?(ActiveRecord)
  ActiveRecord::Base.extend(Guise::Syntax)
end
