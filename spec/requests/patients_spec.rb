require 'spec_helper'

include Warden::Test::Helpers
Warden.test_mode!


describe "patient checks" do
  before do
    visit root_path
  end
    it "should populate patient_assessment" do
      click_link 'Pre-op assessment'
      fill_in '[data-short-name]="patient_surname"', with: "John"
      click_button "Submit"
      page.should have_content "Assessment was successfully created"
    end




    #describe "assessments checks " do
    #  let(:patient) { create(:patient) }
    #
    #  it "should not see other patients assessments" do
    #
    #  end
    #end


      #let(:user) { FactoryGirl.create ( :user ) }
    #let(:user) { User.create!*(:name ) }
    #let(:patient2) { FactoryGirl.create ( :patient ) }

    #before do
    #  sign_in user
    #  #visit root_path
    #end
    #user.should be_an_instance_of(User)
    #user.assign_role('patient')
    #user.patient.should be_an_instance_of(Patient)
    #patient2.should be_an_instance_of(Patient)
    #
    #puts patient2.to_param


    #  visit patient_path patient2
    #  response.status.should be(302)
    #end

    #Run the generator again with the --webrat flag if you want to use webrat methods/matchers
    #get questions_path
    #patient.user.should eq(user)

end
