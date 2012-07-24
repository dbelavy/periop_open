# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :patient do
    sequence(:email) {|n| "email#{n}@factory.com" }
    sequence(:firstname) {|n| Faker::Name.first_name}
    sequence(:surname) {|n| Faker::Name.last_name}
    sequence(:ssn) {Random.rand(1000000).to_s}
    sequence(:planned_date_of_surgery) { Date.current.advance(:days=> Random.rand(1..55)) }
    dob "1961-04-12"
  end
end
