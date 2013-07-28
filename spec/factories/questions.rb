# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :question do
    input_type 'Free_text'
    concept
    condition "MyString"
    short_name "MyString"
  end
end

