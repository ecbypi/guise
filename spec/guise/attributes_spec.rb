require 'spec_helper'

module Guise
  describe Attributes do

    it "defines methods to access @@guise_attributes" do
      User.should respond_to :guises
      User.should respond_to :guise_table
      User.should respond_to :guise_attribute
    end
  end
end
