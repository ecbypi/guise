require 'spec_helper'

module Guise
  describe Introspection do
    let!(:user) { create(:user) }
    let!(:technician) { create(:technician) }
    let!(:supervisor) { create(:supervisor) }

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
    end
  end
end
