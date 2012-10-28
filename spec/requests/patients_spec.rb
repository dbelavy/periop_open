require 'spec_helper'

describe "Patients" do
  before :each do
    create_professional(Professional::ANESTHETIST,"alexander.khitev@gmail.com","Alexander Khitev")
    Patient.create!(firstname: "Firstname")

  end

  describe "GET /patients" do
    it "should filter patients assigned to others anesthetists" do
      #PatientsDatatable.new(ActionView.new,Ability.new())


    end
  end
end
