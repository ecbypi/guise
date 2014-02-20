# guise

An alternative to storing role resources in the database.

`guise` uses a `has_many` association to store type information instead of
using `has_many :through` or `has_and_belongs_to_many.` The `has_many` association
stores the role or type information as a string representing the class name.

If effect, `guise` enables 'multi-table-inheritance'.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'guise'
```

And then execute:

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
rails generate model user_role user:references title:string
rake db:migrate
```

Then add `has_guises` to your model. This will setup the `has_many` association
for you. It requires the name of the association and name of the column that
the sublcass name will be stored in.

```ruby
class User < ActiveRecord::Base
  has_guises :desk_worker, :mail_forwarder, :association => :user_roles, :attribute => :title
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
  guise_for :user
end
```

This method does the following:
* Sets up `belongs_to` association and accepts the standard options.
* Validates the column storing the name of the guise in the list supplied is
  unique to the resource it belongs to and is one of the provided names.

To add a class for each guise, call `:guise_of` in a subclass:

```ruby
class DeskWorker < User
  guise_of :user
end
```

This adds the following to the `DeskWorker` class:

```ruby
class DeskWorker < User
  default_scope -> { joins(:user_roles).where(user_roles: { title: 'DeskWorker'}) }

  after_initialize do
    self.guises.build(title: 'DeskWorker')
  end

  after_create do
    self.guises.create(title: 'DeskWorker')
  end
end
```

### Customization

If the association doesn't standard association assumptions, you can pass in
the options for `has_many` into `has_guises`. The same applies to `guise_for`
with the addition that you can specify not to validate attributes.

```ruby
class Person < ActiveRecord::Base
  has_guises :admin, :engineer,
             :association => :positions,
             :attribute => :rank,
             :foreign_key => :employee_id,
             :class_name => :JobTitle
end

class JobTitle < ActiveRecord::Base
  guise_for :person,
            :foreign_key => :employee_id,
            :validate => false # skip setting up validations
end
```
