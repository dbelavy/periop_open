require 'rspec'
require "cancan/matchers"
require 'data_setup_helper'

describe "abilities" do

  context "when user is an assistant" do
    before :each do
      setup_anesthetist
      setup_assistant

      @ability = Ability.new @assistant_user
      @patient = create(:patient,:anesthetist_id => @anesthetist.id)


      form = create :form
      puts 'form ' + form.inspect
      puts 'question ' + form.questions[0].inspect
      puts 'concept ' + form.questions[0].concept.inspect
      #@concept = create(:concept)
      @unassigned_assessment = Assessment.new
      @unassigned_assessment.anesthetist_id = @anesthetist.id
    end

    it "have access to returns anesthetist id as bson id" do
      @assistant.has_access_to.should eq([@anesthetist.id])
    end
    it "able to see anesthetist patients" do
      @ability.should be_able_to(:read,@patient)
    end

    it "able to see unassigned_assessment referenced anesthetist" do

    @ability.should be_able_to(:read,@unassigned_assessment)
    @ability.should be_able_to(:edit,@unassigned_assessment)
    end


  end
end