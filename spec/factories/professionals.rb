# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :professional do
    factory :anesthetist do
      speciality Professional::ANESTHETIST
    end
  end
end
