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

Then add the `guises` call to your model. If your table name is different or
you want a different attribute, supply the `:as` and `:attribute` options.

```ruby
class User < ActiveRecord::Base
  has_many :guises
  guises :DeskWorker, :MailFowarder
end

class Person < ActiveRecord::Base
  has_many :guises
  guises :Admin, :Engineer, :as => :positions, :attribute => :rank
end
```

This adds the following methods to the `User` class:
* `:desk_workers` and `:mail_forwarders` scopes
* `:has_role?` that checks if a user is a particular type
* `:desk_worker?`, `:mail_forwarder` that proxy to `:has_role?`
* `:has_roles?` that checks if a user is of any of the types supplied

Additionally, this creates classes `DeskWorker` and `MailForwarder` that:
* Inherit from `User`.
* Have default scopes for `:desk_workers` and `:mail_forwarders` respectively.
* Create users with the right associated occupation.


## Plans

* Provide generators for roles table
* Update `guise` method to setup `has_many` association
