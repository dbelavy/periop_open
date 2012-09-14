require 'spec_helper'
require 'integration_spec_helper'

include Warden::Test::Helpers




data = YAML::load(File.read('spec/integration/initial_data.yml'))
  describe "patient_assessments" ,:js => true do
    data = YAML::load(File.read('spec/integration/initial_data.yml'))
    puts data[:patients_assessments].to_s
    it "should populate patient assessment"  ,:js => true do
      populate_patient_assessments data[:patients_assessments]
    end
  end


describe "patient_create" ,:js => true do
  it "should create patient " do
    puts 'should create patient javascript_driver  :' + Capybara.javascript_driver.to_s
    create_patient data
    end
  end