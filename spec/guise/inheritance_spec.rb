require 'spec_helper'

module Guise
  describe Inheritance do
    let!(:user) { create(:user) }
    let!(:technician) { create(:technician) }
    let!(:supervisor) { create(:supervisor) }

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
  end
end
