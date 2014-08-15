require 'spec_helper'
require 'integration_spec_helper'
require 'data_setup_helper'
require 'helpers.rb'
#require_relative '../../lib/tasks/parse_questions.rake'
require 'capybara/rspec'

#Rake::Task.clear # necessary to avoid tasks being loaded several times in dev mode
#Periop::Application.load_tasks # providing your application name is 'sample'

include Warden::Test::Helpers


describe "professional tests" do

  data = HashWithIndifferentAccess.new(YAML::load(File.read('spec/integration/initial_data.yml')))

  before :all do

    # TODO move this for some long version test
    # Rake::Task['db:update_questions'].invoke
  end

  context "as professional" do

    before :each do
      setup_anesthetist
      setup_patient_assessment @anesthetist
      login(@anesthetist_user)

    end

    describe "session expiry", :js => true do
      it "give message on session expiry" do
        last_access = Time.now
        # some hack for altering timeout value
        class User
          def timeout_in
            1.second
          end
        end
        sleep 1
        @anesthetist_user.timedout?(last_access).should be_true
        # just any restricted
        visit "/users/edit"
        # it should have only one error box
        expect(page.all(:css, '.alert-error').size).to eq 1
        #screenshot
      end
    end

    describe "patient_assessments", :js => true do

      before :each do
        visit '/'
      end

      it "should display assessment page" do
        expect(page).to have_content ("Patient Assessments")
        expect(page).to have_link("Procedure management")
        "expect name from assessment present"
        expect(page).to have_content "John"
      end

      it "should display assessments"
      #data = YAML::load(File.read('spec/integration/initial_data.yml'))
      #puts data[:patients_assessments].to_s
      it "should populate patient assessment", :js => true do
        #100.times do |index|
        #  populate_generated_patient_assessment (10000 * index + rand(10000)) ,options[:professionals][0]
        #end
      end
    end


    describe "patient_create", :js => true, :disabled => true do
      it "should create patient " do
        puts 'should create patient javascript_driver  :' + Capybara.javascript_driver.to_s
        data = YAML::load(File.read('spec/integration/initial_data.yml'))

        should_have_no_errors
        create_patient data[:patients][0][:answers]
      end
    end

    describe "pair_create", :js => true, :disabled => true do
      it "should create patient " do
        #puts 'should create patient javascript_driver  :' + Capybara.javascript_driver.to_s
        #data = YAML::load(File.read('spec/integration/initial_data.yml'))
        #professional = data[:professionals][rand(2)]
        #200.times do |index|
        #  number = (10000 * index + rand(10000))
        #        populate_generated_patient_assessment number,professional
        #        create_generated_patient number, professional
        #end

      end
    end

    describe "assign", :js => true, :disabled => true do
      it "should create patient " do
        #data = YAML::load(File.read('spec/integration/initial_data.yml'))
        #assign_assessments data[:professionals][0]
      end
    end
  end
end
