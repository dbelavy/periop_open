require 'spec_helper'
require 'integration_spec_helper'
require 'helpers.rb'
#require_relative '../../lib/tasks/parse_questions.rake'
require 'capybara/rspec'
require 'data_setup_helper'

#Rake::Task.clear # necessary to avoid tasks being loaded several times in dev mode
#Periop::Application.load_tasks # providing your application name is 'sample'

include Warden::Test::Helpers


describe "patient tests" do

  before :each do
    @anesthetist = setup_anesthetist
    @other_anesthetist = setup_anesthetist
    doctor_patient_form @anesthetist
    default_patient_form.save!
    visit "/"
  end

  describe "start page", :js => true do
    it "should display choose doctor" do
      expect(page).to have_content ("Select your doctor")
      expect(page).to have_css("#doctor")
    end
  end

  describe "when no doctor selected", :js => true do
    it "should display patient assesssment" do
    click_button "Fill in assessment"
    should_have_no_errors
    page.should_not have_content 'doctor specific ' + @anesthetist.name
    end
  end

  describe "when doctor selected", :js => true do
    it "should display patient assesssment" do
      page.find('#doctor/option[text()="' + @anesthetist["name"] + '"]').select_option
      click_button "Fill in assessment"
      should_have_no_errors
      page.should have_content 'doctor specific ' + @anesthetist.name
      fill_answers(fill_patient_assessment_data 'john dow')
      select_random_values
      click_button "Submit"
      page.should have_content "assessment has been sent"
      a = Assessment.all.first
      expect(a.get_anesthetist_id).eql? @anesthetist._id
    end
  end

  describe "when other doctor selected", :js => true do
    it "should display patient assesssment" do
      page.find('#doctor/option[text()="' + @other_anesthetist["name"] + '"]').select_option
      click_button "Fill in assessment"
      should_have_no_errors
      page.should_not have_content 'doctor specific ' + @anesthetist.name
    end
  end
end
