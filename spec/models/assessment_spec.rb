require 'spec_helper'

describe Assessment do
  describe "validation" do
    before(:each) do
      @form = create(:form)
      @question = create(:question,id: 1)
      @form.questions << @question
      @assessment = build(:assessment)
      @assessment.form = @form
    end

    context "non empty answers" do
    before (:each) do
      @assessment.find_or_create_answer(@question).value = "some value"
    end
    specify {@assessment.should be_valid }

    context "with required question" do
      before(:each) do
        @required_question = create(:question)
        @required_question.required = 'Y'
        @assessment.form.questions << @required_question
        @assessment.find_or_create_answer(@required_question)
      end
      specify {@assessment.should_not be_valid }
      context "with answered required questions" do
        before(:each) do
          @assessment.find_or_create_answer(@required_question).value = 'other value'
        end
        specify {@assessment.should be_valid }
      end
    end

    end

  end
end
