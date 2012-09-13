require 'spec_helper'
require 'integration_spec_helper'

include Warden::Test::Helpers

data = YAML::load(File.read('spec/integration/initial_data.yml'))
  describe "patient assesment check" ,:js => true do
    it "should populate patient assessment"  ,:js => true do
      puts ' data[:patients] ' + data[:patients][0].to_s
      populate_patient_assessment data[:patients][0]
    end
  end


describe "patient_creation" ,:js => true do
  it "should create patient " do
    puts 'should create patient javascript_driver  :' + Capybara.javascript_driver.to_s
    create_patient data
    end
  end