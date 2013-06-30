require 'spec_helper'
require 'integration_spec_helper'
require 'helpers.rb'
#require_relative '../../lib/tasks/parse_questions.rake'

Rake::Task.clear # necessary to avoid tasks being loaded several times in dev mode
Periop::Application.load_tasks # providing your application name is 'sample'

include Warden::Test::Helpers


describe "patient tests" do

data = HashWithIndifferentAccess.new(YAML::load(File.read('spec/integration/initial_data.yml')))

before :all do

  # TODO leave this for some long version test
  # Rake::Task['db:update_questions'].invoke
end

before :each do
  pending
  create_professional(data[:professionals][0])
end


  describe "patient_assessments" ,:js => true, :disable => true do
    #data = YAML::load(File.read('spec/integration/initial_data.yml'))
    #puts data[:patients_assessments].to_s
    it "should populate patient assessment"  ,:js => true do
      #100.times do |index|
      #  populate_generated_patient_assessment (10000 * index + rand(10000)) ,options[:professionals][0]
      #end
    end
  end


describe "patient_create" ,:js => true do
  it "should create patient " do
    puts 'should create patient javascript_driver  :' + Capybara.javascript_driver.to_s
    data = YAML::load(File.read('spec/integration/initial_data.yml'))
    login data[:professionals][0]
    should_have_no_errors
    create_patient data[:patients][0][:answers]
  end
end

describe "pair_create" ,:js => true, :disable => true do
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

describe "assign" ,:js => true, :disable => true  do
  it "should create patient " do
    #data = YAML::load(File.read('spec/integration/initial_data.yml'))
    #assign_assessments data[:professionals][0]
  end
end
end
