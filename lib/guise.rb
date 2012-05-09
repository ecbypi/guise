require 'guise/version'
require 'guise/options'
require 'guise/inheritance'
require 'guise/introspection'

module Guise

  def has_guises(*names)
    add_guise_methods(self)

    options = names.last.is_a?(Hash) ? names.pop : {}
    class_names = names.map(&:to_s).map(&:classify)

    guise_options = set_guise_options(class_names, options)

    build_guises(class_names, guise_options)
    introspect_guises(class_names)
  end

  private

  def add_guise_methods(model)
    model.extend Inheritance
    model.extend Options
    model.send :include, Introspection
  end
end

ActiveRecord::Base.extend Guise
