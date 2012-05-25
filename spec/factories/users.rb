# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    sequence(:email) {|n| "email#{n}@factory.com" }
    password 'please'
    password_confirmation { |u| u.password }
    # required if the Devise Confirmable module is used
    confirmed_at Time.now

    factory :patient_user do
      user_role 'patient'
      patient{ Factory.build(:patient)}
    end

    factory :doctor_user do
      user_role 'doctor'
      doctor
    end
  end
end

