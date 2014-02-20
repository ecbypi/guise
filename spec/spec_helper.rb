require 'active_record'
require 'factory_girl'
require 'shoulda-matchers'
require 'guise'

ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database => ':memory:'
)

ActiveRecord::Migration.verbose = false

ActiveRecord::Schema.define do
  create_table :users, :force => true do |t|
    t.string :name
    t.string :email
  end

  create_table :user_roles, :force => true do |t|
    t.string :name
    t.integer :person_id
  end
end

class User < ActiveRecord::Base
  has_guises :Technician, :Supervisor,
             :association => :user_roles,
             :attribute => :name,
             :foreign_key => :person_id
end

class UserRole < ActiveRecord::Base
  guise_for :user,
            :foreign_key => :person_id
end


FactoryGirl.find_definitions
RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
end
