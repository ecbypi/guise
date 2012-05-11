# Inspired/borrowed from @ernie's way of building out a database in
# ransack and squeel

ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database => ':memory:'
)

class User < ActiveRecord::Base
  has_guises :Technician, :Supervisor,
             :association => :user_roles,
             :attribute => :name,
             :foreign_key => :person_id
end

class UserRole < ActiveRecord::Base
  belongs_to :user, :foreign_key => :person_id
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
          t.integer :person_id
        end
      end
    end
  end
end
