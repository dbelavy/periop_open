# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :form do
    sequence(:name) {|n| "name #{n}" }
  end
end
