# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :patient do
    sequence(:email) {|n| "email#{n}@factory.com" }
    password { |u| u.dob }
    password_confirmation { |u| u.password }
    sequence(:name) {|n| Faker::Name.name}
    sequence(:ssn) {Random.rand(1000000).to_s}
    sequence(:planned_date_of_surgery) { Date.current.advance(:days=> Random.rand(1..55)) }
    dob "1961-04-12"
  end
end
