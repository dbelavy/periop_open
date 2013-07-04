# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :assessment do
    form
    answers {[FactoryGirl.build(:answer),FactoryGirl.build(:answer)]}
  end
end
