# guise

An alternative to storing role resources in the database.

guise delegates type information to roles table that determines what a resource
can be instantiated as. In essence, it's similar to single table inheritance,
but with multiple inheritances possible.


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
rails generate model guises user:references title:string
rake db:migrate
```

Then add call the `has_guises` method in your model. This will setup the
`has_many` association for you.

```ruby
class User < ActiveRecord::Base
  has_guises :DeskWorker, :MailFowarder
end
```

This adds the following methods to the `User` class:
* `:desk_workers` and `:mail_forwarders` scopes.
* `:has_role?` that checks if a user is a particular type.
* `:desk_worker?`, `:mail_forwarder` that proxy to `:has_role?`.
* `:has_roles?` that checks if a user is of any of the types supplied.

And creates classes `DeskWorker` and `MailForwarder` that:
* Inherit from `User`.
* Have default scopes for `:desk_workers` and `:mail_forwarders` respectively.
* Create users with the right associated occupation.


To configure the other end of the association, add `guise_for`:

```ruby
class Guise < ActiveRecord::Base
  guise_for :user
end
```

This method does the following:
* Sets up `belongs_to` association and accepts the standard options.
* Validates the column storing the name of the guise in the list supplied is
  unique to the resource it belongs to and is one of the provided names.


### Customization

If the association doesn't fit what is assumed, you can pass in the options for
`has_many` into `has_guises`. The same applies to `guise_for` with the addition that you can specify not to validate attributes 

```ruby
class Person < ActiveRecord::Base
  has_guises :Admin, :Engineer,
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


## The Future

* Provide generators for roles table
* Update `has_guises` method to setup `has_many` association
* Adding validations on `guise_attribute` column into association class
