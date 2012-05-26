require 'spec_helper'

include Warden::Test::Helpers
Warden.test_mode!


describe "authorisation checks" do

  describe "for signed in patient " do
    puts 'before create'

    let(:user1) { create(:patient_user) }
    let(:user2) { create(:patient_user) }

    it "should be not access other patient" do
      Warden.test_reset!
      puts user1.email
      puts user2.email
      user2.patient?.should be_true
      user2.patient.user.should eq user2
      user2.should_not eq user1
      user2.patient.should_not eq user1.patient
      login_as(user1, :scope => :user)
      visit patient_path user1.patient
        response.status.should be(200)
      visit '/patients/'
      response.status.should be(302)
      visit patient_path user2.patient
      response.status.should be(302)
    end

    it "sould not see patients" do

    end


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
end
