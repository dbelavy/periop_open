require 'spec_helper'

describe Professional do
  pending "add some examples to (or delete) #{__FILE__}"


  it "should create profesional with related user " do
    @attr = {
           :name => "Test ",
           :speciality => Professional::ANAESTHETIST
       }

    professional = Professional.new(@attr)
    professional.user = User.new(:email => 'foo@example.com')
    professional.create_professional.should be_true
    professional.user.should_not be_nil
  end
end
