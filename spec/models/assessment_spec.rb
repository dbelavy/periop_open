require 'spec_helper'
require 'data_setup_helper'

describe Assessment do
  before(:each) do
    @form = create(:form)
    @question = create(:question, id: 1)
    @form.questions << @question
    @assessment = build(:assessment)
    @assessment.form = @form
  end

  describe "validation" do

    context "non empty answers" do
      before (:each) do
        @assessment.find_or_create_answer(@question).value = "some value"
      end
      specify { @assessment.should be_valid }

      context "with required question" do
        before(:each) do
          @required_question = create(:question)
          @required_question.required = 'Y'
          @assessment.form.questions << @required_question
          @assessment.find_or_create_answer(@required_question)
        end
        specify { @assessment.should_not be_valid }
        context "with answered required questions" do
          before(:each) do
            @assessment.find_or_create_answer(@required_question).value = 'other value'
          end
          specify { @assessment.should be_valid }
        end
      end
    end
  end

  context  "attach to anesthetist " do
    before(:each) do
      @assessment.form.questions << setup_questions
      @anesthetist = setup_anesthetist
      @other_anesthetist = setup_anesthetist
    end

    context "with doctor_name " do
      before(:each) do
        @assessment.doctor_name = @anesthetist.name
      end
      specify { @assessment.get_anesthetist_id.should  eq @anesthetist._id }
    end

    context "with anesthetist as question" do
      before do
        question = Question.by_concept(Concept.find_by_name 'anesthetist')
        @assessment.find_or_create_answer(question).id_value = @anesthetist._id
        @assessment.save
      end
      specify { @assessment.get_anesthetist_id.should  eq @anesthetist._id.to_s }
    end
  end
end
