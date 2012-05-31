# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :patient do
    sequence(:email) {|n| "email#{n}@factory.com" }
    password '123456'
    password_confirmation { |u| u.password }
    sequence(:name) {|n| Faker::Name.name}
    sequence(:ssn) {Random.rand(1000000).to_s}
    dob "1965-05-21"
  end
end
