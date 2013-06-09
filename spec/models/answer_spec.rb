require 'spec_helper'


describe "Answer" do
  describe "validation" do
    before(:each) do
      @assessment = stub.as_null_object
      @question = create(:question)
      @answer = create(:answer,question: @question,assessment: @assessment)
    end
    it "do not check value presence" do
      expect(@answer.valid?)
    end
    it "check value presence is required = Y" do
      @question.required = 'Y'
      expect(@answer.valid?).to be_false
    end

  end

end
