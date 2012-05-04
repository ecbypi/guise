require 'guise/version'
require 'guise/attributes'
require 'guise/inheritance'
require 'guise/introspection'

module Guise
  def self.extended(base)
    base.extend Inheritance
    base.extend Attributes
    base.send :include, Introspection
  end

  def has_guises(*names)
    options = names.last.is_a?(Hash) ? names.pop : {}
    class_names = names.map(&:to_s).map(&:classify)

    set_attributes(class_names, options)
    build_guises
  end
end

ActiveRecord::Base.extend Guise
