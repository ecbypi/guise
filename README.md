# guise

[![Build Status](https://travis-ci.org/ecbypi/guise.png?branch=master)](https://travis-ci.org/ecbypi/guise)
[![Code Climate](https://codeclimate.com/github/ecbypi/guise.png)](https://codeclimate.com/github/ecbypi/guise)

A typical quick-to-setup role management system involves `users` and `roles`
tables with a join table between them to determine membership to a role. A
problem with this is that application behavior then depends on corresponding
records existing in the `roles` table. When testing, `Role` records need to be
created for each test run they're used in, but need to be only created once to
ensure uniqueness. Additionally, adding a new role requires a data migration to
insert the role in production.

`guise` de-normalizes the above setup by storing the name of the role as a
column in what would be the join table between `users` and `roles`.  For
example, assume a `users` table and `roles` table where the `roles` table has a
`title` column represented by the following `activerecord` classes:

```ruby
class User < ActiveRecord::Base
end

class Role < ActiveRecord::Base
end
```

By adding the method call `has_guises` to `User` and `guise_for` to
`Role`:

```ruby
class User < ActiveRecord::Base
  has_guises :DeskWorker, :MailForwarder, association: :roles, attribute: :title
end

class Role < ActiveRecord::Base
  guise_for :User
end
```

The equivalent associations, model scopes, methods and validations are
configured:

```ruby
class User < ActiveRecord::Base
  has_many :roles

  scope :desk_workers, -> { joins(:roles).where(roles: { title: "DeskWorker" }) }
  scope :mail_forwarders, -> { joins(:roles).where(roles: { title: "MailForwarder" }) }

  def has_role?(title)
    roles.detect { |role| role.title == title }
  end

  def has_roles?(*titles)
    titles.all? { |title| has_role?(title) }
  end

  def has_any_roles?(*titles)
    titles.any? { |title| has_role?(title) }
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

  scope :desk_workers, -> { where(title: "DeskWorker") }
  scope :mail_forwarders, -> { where(title: "MailForwarder") }

  validates(
    :title,
    presence: true,
    uniqueness: { scope: :user_id },
    inclusion: { in: %w( DeskWorker MailForwarder ) }
  )
end
```

This allows filtering by role and assigning records to a role without requiring
an existing record in the database to represent it. The predicate methods can be
used for permissions / authorization.

It is also possible to define subclasses of `Role` and `User` that are
automatically scoped to the record associated with that role. This is described
in greater detail below.

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
rails generate model role user:references title:string:uniq
rake db:migrate
```

It is recommended to add a unique index on the foreign key and guise attribute
columns and a single-column index on the guise attribute column.  In this case
the columns are `user_id` and `title`.

```ruby
class CreateRoles < ActiveRecord::Migration
  def change
    create_table do |t|
      t.string :title
      t.references :user, index: true
      t.timestamps
    end

    add_index :roles, [:user_id, :title], unique: true
    add_index :roles, :title
  end
end
```

Then add `has_guises` to your model. This will setup the `has_many` association
for you. It requires the name of the association and name of the column that
the role value will be stored in.

```ruby
class User < ActiveRecord::Base
  has_guises :DeskWorker, :MailForwarder, association: :user_roles, attribute: :title
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
  default_scope -> { joins(:roles).where(roles: { title: "DeskWorker"}) }

  after_initialize do
    self.guises.build(title: "DeskWorker")
  end
end
```

To scope the association class to a role, use `scoped_guise_for`. The name of
the class must be `<guise_value><association_class_name>` (i.e. the role it
represents combined with the name of the parent class).

```ruby
class DeskWorkerUserRole < UserRole
  scoped_guise_for :User
end
```

This sets up the class as follows:

```ruby
class DeskWorkerUserRole < UserRole
  default_scope -> { where(title: "DeskWorker") }

  after_initialize do
    self.title = "DeskWorker"
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
