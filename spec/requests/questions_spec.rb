require Rails.root.join('spec', 'helpers.rb')
require 'spec_helper'

describe "Questions" do
  it "check condition test" do
    true.should be_true
    check_conditon("Country = Australia").should be_true
  end
end
