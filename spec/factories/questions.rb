# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :question do
    display_conditions "MyString"
    short_name "MyString"
    clinical_terms "MyString"
    question_for_patient "MyString"
    compulsory_for_patient_reported_assessment "MyString"
    input_type "MyString"
    option_list "MyString"
    used_in_patient_assessment "MyString"
    used_in_phone_assessment "MyString"
    snomed_concept "MyString"
  end
end
