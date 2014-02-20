require 'active_support/concern'
require 'active_support/core_ext/hash/keys'
require 'active_support/core_ext/string/inflections'

require 'guise/version'
require 'guise/lifecycle_callback'

module Guise
  extend ActiveSupport::Concern

  included do
    class_attribute :guise_options
  end

  module ClassMethods
    def has_guises(*guises)
      options = guises.last.is_a?(Hash) ? guises.pop : {}

      guises      = guises.map { |g| g.to_s.classify }
      association = options.fetch(:association)
      attribute   = options.fetch(:attribute)

      self.guise_options = {
        :names       => guises,
        :association => association,
        :attribute   => attribute
      }

      guises.each do |guise|
        method_name = guise.underscore
        scope method_name.pluralize, -> { joins(association).where(association => { attribute => guise }) }

        define_method "#{method_name}?" do
          has_guise?(guise)
        end
      end

      has_many association, options.except(:association, :attribute)

      if association != :guises
        association_singular = association.to_s.singularize

        alias_method :guises, association
        alias_method "has_#{association_singular}?", :has_guise?
        alias_method "has_#{association}?", :has_guises?
        alias_method "has_any_#{association}?", :has_any_guises?
      end
    end

    def guise_of(name)
      klass = name.to_s.classify.constantize

      if klass.guise_options.nil?
        raise ArgumentError, "no guises defined on #{klass.name}"
      end

      default_scope -> { send(model_name.plural) }

      after_initialize LifecycleCallback.new(model_name.to_s)
      after_create LifecycleCallback.new(model_name.to_s)
    end

    def guise_for(name, options = {})
      klass = name.to_s.classify.constantize

      if klass.guise_options.nil?
        raise ArgumentError, "no guises defined on #{klass.name}"
      end

      foreign_key = options[:foreign_key] || "#{klass.model_name.singular}_id"

      belongs_to name, options.except(:validate)

      if options[:validate] != false
        validates klass.guise_options[:attribute], :uniqueness => { :scope => foreign_key }, :presence => true, :inclusion => { :in => klass.guise_options[:names] }
      end
    end
  end

  def has_guise?(value)
    value = value.to_s.classify

    unless guise_options[:names].any? { |name| name == value }
      raise ArgumentError, "no such guise #{value}"
    end

    guises.any? { |g| g[guise_options[:attribute]] == value }
  end

  def has_any_guises?(*values)
    values.any? { |v| has_guise?(v) }
  end

  def has_guises?(*values)
    values.all? { |v| has_guise?(v) }
  end

  private

  def guise_options
    self.class.guise_options
  end
end

if defined?(ActiveRecord)
  ActiveRecord::Base.send(:include, Guise)
end
