require "byebug"
require 'pry'
require 'guise'
require 'active_record'
require "active_record/base"

if I18n.respond_to?(:enforce_available_locales)
  I18n.enforce_available_locales = false
end

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: ':memory:'
)

ActiveRecord::Migration.verbose = false

ActiveRecord::Schema.define do
  create_table :users, force: true do |t|
    t.string :email
  end

  create_table :user_roles, force: true do |t|
    t.string :name
    t.integer :user_id
  end

  create_table :people, force: true do |t|
  end

  create_table :privileges, force: true do |t|
    t.integer :employee_id
    t.string :privilege
  end
end

class User < ActiveRecord::Base
  has_guises :Technician, :Supervisor, :Explorer, association: :user_roles, attribute: :name
end

class Technician < User
  guise_of :User
end

class Supervisor < User
  guise_of :User
end

class UserRole < ActiveRecord::Base
  guise_for :User
end

class TechnicianUserRole < UserRole
  scoped_guise_for :User
end

class Person < ActiveRecord::Base
  has_guises(
    :Admin,
    :Manager,
    :Reviewer,
    association: :permissions,
    attribute: :privilege,
    foreign_key: :employee_id
  )
end

class Permission < ActiveRecord::Base
  self.table_name = :privileges

  guise_for :Person, foreign_key: :employee_id, validate: false
end

RSpec.configure do |config|
  config.order = 'random'
end
