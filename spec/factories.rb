FactoryGirl.define do

  factory :user do
    name 'Micro Helpline'
    email 'mrhalp@mit.edu'

    factory :technician do
      after_create do |user|
        FactoryGirl.create(:user_role, :name => 'Technician', :user => user)
      end
    end

    factory :supervisor do
      after_create do |user|
        FactoryGirl.create(:user_role, :name => 'Supervisor', :user => user)
      end
    end
  end

  factory :user_role do
    association :user
    name 'Technician'
  end
end