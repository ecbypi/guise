require 'spec_helper'

describe Guise do
  let!(:user) { create(:user) }
  let!(:supervisor) { create(:supervisor) }
  let!(:technician) { create(:technician) }

  after do
    User.delete_all
  end

  describe ".has_guises" do
    it "sets up has_many association" do
      user.should have_many :user_roles
    end

    it "adds scopes for each type" do
      technicians = User.technicians

      technicians.should include technician
      technicians.should_not include user
      technicians.should_not include supervisor
    end
  end

  describe "#has_guise?" do
    it "checks if record is of the specified type" do
      user.should_not have_guise :technician

      technician.should have_guise :technician
      technician.should have_guise :Technician
      technician.should have_guise 'Technician'
      technician.should have_guise 'technician'
      technician.should have_guise Technician
    end

    it "raises an error if type was not specified" do
      expect { user.has_guise?(:Accountant) }.to raise_error ArgumentError
    end

    it 'is aliased based on the name of the association' do
      user.should_not have_user_role :technician
      technician.should have_user_role :technician
    end

    it 'is wrapped for each guise specified' do
      user.should_not be_technician
      technician.should be_technician
    end
  end

  describe "#has_guises?" do
    before do
      @role = create(:user_role, :name => 'Technician', :user => supervisor)
    end

    after do
      @role.destroy
    end

    it "checks if resource is all of the provided types" do
      technician.should_not have_guises :Supervisor, :Technician
      supervisor.should have_guises :Supervisor, :Technician
    end

    it 'is aliased based on the association name' do
      technician.should_not have_user_roles :Supervisor, :Technician
      supervisor.should have_user_roles :Supervisor, :Technician
    end
  end

  describe "#has_any_roles?" do
    it "checks if resource is any of the supplied roles" do
      user.should_not have_any_guises :Supervisor, :Technician
      technician.should have_any_guises 'supervisor', 'technician'
    end

    it 'is aliased based on the association name' do
      user.should_not have_any_user_roles :Supervisor, :Technician
      technician.should have_any_user_roles 'supervisor', 'Technician'
    end
  end

  describe '.guise_of' do
    it "sets default scope to limit to records of the class's type" do
      technician_ids = Technician.pluck(:id)

      technician_ids.should eq [technician.id]
    end

    it 'sets up lifecycle callbacks to ensure records are initialized and created with the correct associated records' do
      new_record = Technician.new
      new_record.should have_guise :technician

      created_record = Technician.create!
      created_record.should have_guise :technician
    end
  end

  describe ".guise_for" do
    subject { UserRole.new }

    it "sets up belongs_to" do
      should belong_to(:user)
    end

    describe "adds validations to ensure guise attribute is" do
      it "present" do
        should validate_presence_of(:name)
      end

      it "unique per resource" do
        should validate_uniqueness_of(:name).scoped_to(:person_id)
      end

      it "is one of the guise names provided" do
        expect { create(:user_role, :name => 'Farmer') }.to raise_error ActiveRecord::RecordInvalid
      end
    end
  end
end
