# Inspired/borrowed from @ernie's way of building out a database in
# ransack and squeel

require 'active_record'
require 'guise'

ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database => ':memory:'
)

class User < ActiveRecord::Base
  has_many :user_roles
  has_guises :Technician, :Supervisor, :as => :user_roles, :attribute => :name
end

class UserRole < ActiveRecord::Base
  belongs_to :user
end

module Database
  def self.create
    ActiveRecord::Base.silence do
      ActiveRecord::Migration.verbose = false

      ActiveRecord::Schema.define do
        create_table :users, :force => true do |t|
          t.string :name
          t.string :email
        end

        create_table :user_roles, :force => true do |t|
          t.string :name
          t.integer :user_id
        end
      end
    end
  end
end
