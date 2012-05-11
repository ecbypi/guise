require 'spec_helper'

describe Guise do

  let(:user) { create(:user) }
  let(:supervisor) { create(:supervisor) }
  let(:technician) { create(:technician) }

  describe ".has_guises" do
    subject { user }

    it "sets up has_many association" do
      should have_many :user_roles
    end

    it "builds subclasses of names called in :guise" do
      Technician.new.should be_a User
      Technician.new.guises.should_not be_empty
    end

    it "adds scopes for each type" do
      User.technicians.should include(technician)
      User.technicians.should_not include(user)

      User.supervisors.should include(supervisor)
      User.supervisors.should_not include(user)
    end

    describe "#has_role?" do
      it "checks if resource is of the type provided" do
        user.has_role?(:technician).should be_false
        technician.has_role?(:Technician).should be_true
      end

      it "raises an error if type was not added in :guises call" do
        expect { user.has_role?(:Accountant) }.to raise_error(NameError)
      end
    end

    describe "#has_roles?" do
      before :each do
        create(:user_role, :name => 'Technician', :user => supervisor)
      end

      it "checks if resource is all of the provided types" do
        technician.has_roles?(:Supervisor, :Technician).should be_false
        supervisor.has_roles?('Supervisor', Technician).should be_true
      end
    end

    describe "#has_any_roles?" do
      it "checks if resource is any of the supplied roles" do
        user.has_any_roles?(:Supervisor, :Technician).should be_false
        technician.has_any_roles?('supervisor', 'technician').should be_true
      end
    end

    it "adds methods that proxy to #has_role? for ease" do
      user.should respond_to :technician?
      user.should respond_to :supervisor?

      user.technician?.should be_false
      technician.technician?.should be_true
    end
  end

  describe ".guise_for" do
    subject { create(:user_role) }

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
