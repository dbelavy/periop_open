# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :patient do
    ssn "MyString"
    birth_day "2012-05-21"
  end
end
