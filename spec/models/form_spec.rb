require 'spec_helper'

describe Form do
  before(:each) do
    @form = create(:form)
  end

  it "should have professional_id field" do
    expect(@form.respond_to? :professional_id).to be_true
  end

end
