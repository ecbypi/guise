require 'active_support/concern'
require 'active_support/core_ext/hash/keys'
require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/string/inflections'

module Guise
  module Syntax
    # Setup the model's `guises` association. Given the following setup:
    #
    # ```ruby
    # class User < ActiveRecord::Base
    #   has_guises :DeskWorker, :MailForwarder, association: :roles, attribute: :value
    # end
    # ```
    #
    # The following is configured:
    #
    # * `has_many` association named according to the `:association` option.
    # * `User.desk_workers` and `User.mail_forwarders` model scopes.
    # * `User#has_guise?` that checks if a user is a particular type.
    # * `User#desk_worker?`, `User#mail_forwarder?` that proxy to `User#has_guise?`.
    # * `User#has_guises?` that checks if a user has records for all the types
    #   supplied. This is aliased to `User#has_roles?`.
    # * `User#has_any_guises?` that checks if a user has records for any of the
    #   types supplied. This is aliased to `User#has_any_roles?`.
    # * If the association name is not `:guises`:
    #   * Aliases the association methods to equivalent methods for `guises`
    #     (i.e. `guises=` to `roles=`).
    #   * Aliases the introspection methods (i.e. `has_guise?` to `has_role?`
    #     and `has_any_guises?` to `has_any_roles?`
    #
    # @overload has_guises(*guises, options)
    #   @param [Array<Symbol, String>] *guises names of guises that should be
    #     allowed
    #   @param [Hash] options options to configure the association
    #   @option options [Symbol] :association name of the association to define.
    #     This option is required.
    #   @option options [Symbol] :attribute name of the association's column
    #     where the value of which guise is being represented is stored. This
    #     option is required.
    def has_guises(*guises)
      include Introspection

      Guise.register_source(self, *guises)
    end

    # Specifies that the model is a subclass of a model configured with
    # {#has_guises} specified by `class_name`.
    #
    # Configures the caller with the correct `default_scope`. Given the
    # following definition with `has_guises`:
    #
    # ```ruby
    # class User < ActiveRecord::Base
    #   has_guises :DeskWorker, :MailForwarder, association: :roles, attribute: :title
    # end
    # ```
    #
    # The following call to `guise_of`:
    #
    # class DeskWorker < User
    #   guise_of :User
    # end
    # ```
    #
    # Is equivalent to:
    #
    # ```ruby
    # class DeskWorker < User
    #   default_scope -> { desk_workers }
    #
    #   after_initialize do
    #     self.guises.build(title: 'DeskWorker')
    #   end
    #
    #   after_create do
    #     self.guises.create(title: 'DeskWorker')
    #   end
    # end
    # ```
    #
    # @param [String, Symbol] source_class_name name of the superclass
    #   configured with {#has_guises}.
    def guise_of(source_class_name)
      options = Guise.registry[source_class_name]

      default_scope GuiseOfScope.new(name, options)
      after_initialize SourceCallback.new(name, options.attribute)
    end

    # Configures the other end of the association defined by {#has_guises}.
    # Defines equivalent scopes defined on the model configured with
    # {#has_guises}.
    #
    # Given the following configuring of `has_guises`:
    #
    # ```ruby
    # class User < ActiveRecord::Base
    #   has_guises :DeskWorker, :MailForwarder, association: :roles, attribute: :title
    # end
    # ```
    #
    # The following call to `guise_for`:
    #
    # ```ruby
    # class Role < ActiveRecord::Base
    #   guise_for :User
    # end
    # ```
    #
    # Is equivalent to:
    #
    # ```ruby
    # class Role < ActiveRecord::Base
    #   belongs_to :user
    #
    #   validates :title, presence: true, uniqueness: { scope: :user_id }, inclusion: { in: %w( DeskWorker MailForwarder ) }
    #
    #   scope :desk_workers, -> { where(title: "DeskWorker") }
    #   scope :mail_forwarder, -> { where(title: "MailForwarder") }
    # end
    # ```
    #
    # @param [Symbol, String] source_class_name name of the class configured
    #   with {#has_guises}
    # @param [Hash] options options to configure the `belongs_to` association.
    # @option options [false] :validate specify `false` to skip
    #   validations for the `:attribute` specified in {#has_guises}
    # @option options [Symbol] :foreign_key foreign key used to build the
    #   association.
    def guise_for(source_class_name, options = {})
      Guise.register_association(self, source_class_name, options)
    end

    # Specifies that the model is a subclass of a model configured with
    # {#guise_for} specified by `class_name`. The name of the calling class must
    # be `<value|parent_class_name>`.
    #
    # Given the following configuration with `guise_for`:
    #
    # ```ruby
    # class Role < ActiveRecord::Base
    #   guise_for :User
    # end
    # ```
    #
    # The following call to `scoped_guise_for`:
    #
    # ```ruby
    # class DeskWorkerRole < Role
    #   scoped_guise_for :Role
    # end
    # ```
    #
    # Is equivalent to:
    #
    # ```ruby
    # class DeskWorkerRole < Role
    #   default_scope -> { desk_workers }
    #
    #   after_initialize do
    #     self.title = "DeskWorker"
    #   end
    # end
    # ```
    #
    # @param [Symbol, String] association_class_name name of the superclass
    #   configured with {#guise_for}.
    def scoped_guise_for(association_class_name)
      options = Guise.registry[association_class_name]
      value = name.chomp(options.association_class.name)

      default_scope options.scope(value, :guise_for)
      after_initialize AssociationCallback.new(value, options.attribute)
    end
  end
end
