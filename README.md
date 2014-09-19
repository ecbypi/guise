# guise

[![Build Status](https://travis-ci.org/ecbypi/guise.png?branch=master)](https://travis-ci.org/ecbypi/guise)
[![Code Climate](https://codeclimate.com/github/ecbypi/guise.png)](https://codeclimate.com/github/ecbypi/guise)

A typical, quick-and-easy role management system involves `users` and `roles`
tables with a join table between them to determine membership to a role:

```ruby
class User < ActiveRecord::Base
  has_many :user_roles
  has_many :roles, through: :user_roles
end

class UserRole < ActiveRecord::Bae
  belongs_to :user
  belongs_to :role
end

class Role < ActiveRecord::Base
  has_many :user_roles
  has_many :users, through: :user_roles
end
```

A problem with this is that in simple setups, application behavior tends to be
hard-coded to rely on the existence of a database record representing the role
object in the `roles` table.

`guise` de-normalizes the above setup by storing the name of the role as a
column in what would be the join table between `users` and `roles`. The allowed
values are limited to the values defined in a declaration on the model that is
meant to have different roles.

Given `User` and `Role` models where the `Role` model has a `value` column.

```ruby
class User < ActiveRecord::Base
end

class Role < ActiveRecord::Base
end
```

By adding the following method call to `has_guises` to `User` and `guise_for` to
`Role`:

```ruby
class User < ActiveRecord::Base
  has_guises :DeskWorker, :MailForwarder, association: :roles, attribute: :value
end

class Role < ActiveRecord::Base
  guise_for :User
end
```

The equivalent associations, model scopes and validations are configured:

```ruby
class User < ActiveRecord::Base
  has_many :roles

  scope :desk_workers, -> { joins(:roles).where(roles: { value: "DeskWorker" }) }
  scope :mail_forwarders, -> { joins(:roles).where(roles: { value: "MailForwarder" }) }

  def has_role?(value)
    roles.detect { |role| role.value == value }
  end

  def has_roles?(*values)
    values.all? { |value| has_role?(value)
  end

  def has_any_roles?(*values)
    values.any? { |value| has_role?(value)
  end

  def desk_worker?
    has_role?("DeskWorker")
  end

  def mail_forwarder?
    has_role?("MailForwarder")
  end
end

class Role < ActiveRecord::Base
  belongs_to :user

  scope :desk_workers, -> { where(value: "DeskWorker") }
  scope :mail_forwarders, -> { where(value: "MailForwarder") }

  validates(
    :value,
    presence: true,
    uniqueness: { scope: :user_id },
    inclusion: { in: %w( DeskWorker MailForwarder ) }
  )
end
```

This allows filtering users by role / type and assigning records a role without
requiring an existing record in the database. The predicate methods can be used
for permissions / authorization.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'guise'
```

Then execute:

```
$ bundle
```

Or install it yourself as:

```
$ gem install guise
```

## Usage

Create a table to store your type information:

```
rails generate model role user:references value:string:uniq
rake db:migrate
```

It is recommended to add an index on the foreign key and guise attribute. In
this case the columns are `user_id` and `value`.

Then add `has_guises` to your model. This will setup the `has_many` association
for you. It requires the name of the association and name of the column that
the subclass name will be stored in.

```ruby
class User < ActiveRecord::Base
  has_guises :DeskWorker, :MailForwarder, association: :roles, attribute: :value
end
```

This adds the following methods to the `User` class:
* `:desk_workers` and `:mail_forwarders` model scopes.
* `:has_guise?` that checks if a user is a particular type.
* `:desk_worker?`, `:mail_forwarder` that proxy to `:has_guise?`.
* `:has_guises?` that checks if a user has records for all the types supplied.
* `:has_any_guises?` that checks if a user has records for any of the types supplied.

To configure the other end of the association, add `guise_for`:

```ruby
class UserRole < ActiveRecord::Base
  guise_for :User
end
```

This method does the following:
* Sets up `belongs_to` association and accepts the standard options.
* Validates the column storing the name of the guise in the list supplied is
  unique to the resource it belongs to and is one of the provided names.

### Role Subclasses

If using `User.<guise_scope>` is too tedious, it is possible to setup
subclasses to represent each value referenced in `has_guises` using the
`guise_of` method:

```ruby
class DeskWorker < User
  guise_of :User
end
```

This is equivalent to the following:

```ruby
class DeskWorker < User
  default_scope -> { joins(:roles).where(roles: { value: 'DeskWorker'}) }

  after_initialize do
    self.guises.build(value: 'DeskWorker')
  end
end
```

To scope the association class to a guise, use `scoped_guise_for`. The name of
the class must be `<guise_value><association_class_name>` (i.e. the guise it
represents combined with the name of the parent class.

```ruby
class DeskWorkerUserRole < UserRole
  scoped_guise_for :User
end
```

This sets up the class as follows:

```ruby
class DeskWorkerUserRole < UserRole
  default_scope -> { where(value: "DeskWorker") }

  after_initialize do
    self.value = "DeskWorker"
  end
end
```

### Customization

If the association doesn't standard association assumptions made by
`activerecord`, you can pass in the options for `has_many` into `has_guises`.
The same applies to `guise_for` with the addition that you can specify not to
validate attributes.

```ruby
class Person < ActiveRecord::Base
  has_guises :Admin, :Engineer,
             association: :positions,
             attribute: :rank,
             foreign_key: :employee_id,
             class_name: :JobTitle
end

class JobTitle < ActiveRecord::Base
  guise_for :Person,
            foreign_key: :employee_id,
            validate: false # skip setting up validations
end
```
