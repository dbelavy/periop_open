# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :question do
    condition "MyString"
    short_name "MyString"
  end
end
