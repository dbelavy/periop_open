# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :patient do
    user
    name Faker::Name.name
    ssn "MyString"
    birth_day "1965-05-21"
  end
end
