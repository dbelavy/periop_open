require 'spec_helper'
require 'integration_spec_helper'

include Warden::Test::Helpers




data = YAML::load(File.read('spec/integration/initial_data.yml'))
  describe "patient_assessments" ,:js => true do
    data = YAML::load(File.read('spec/integration/initial_data.yml'))
    puts data[:patients_assessments].to_s
    it "should populate patient assessment"  ,:js => true do
      100.times do |index|
        populate_generated_patient_assessment (10000 * index + rand(10000)) ,options[:professionals][0]
      end
    end
  end


describe "patient_create" ,:js => true do
  it "should create patient " do
    puts 'should create patient javascript_driver  :' + Capybara.javascript_driver.to_s
    data = YAML::load(File.read('spec/integration/initial_data.yml'))
    create_generated_patients data
  end
end

describe "pair_create" ,:js => true do
  it "should create patient " do
    puts 'should create patient javascript_driver  :' + Capybara.javascript_driver.to_s
    data = YAML::load(File.read('spec/integration/initial_data.yml'))
    professional = data[:professionals][rand(2)]
    200.times do |index|
      number = (10000 * index + rand(10000))
            populate_generated_patient_assessment number,professional
            create_generated_patient number, professional
    end

  end
end

describe "assign" ,:js => true do
  it "should create patient " do
    data = YAML::load(File.read('spec/integration/initial_data.yml'))
    assign_assessments data[:professionals][0]
  end
end
