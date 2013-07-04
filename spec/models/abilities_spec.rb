require 'rspec'
require "cancan/matchers"

describe "abilities" do

  context "when user is an assistant" do
    before :each do
      @anesthetist_user = create(:professional_user)
      @assistant_user = create(:professional_user)
      @assistant = @assistant_user.professional
      @assistant
      @anesthetist = @anesthetist_user.professional
      @anesthetist.speciality = Professional::ANESTHETIST
      # important! it is stored as plain string
      @assistant.shared_professionals_ids = [@anesthetist.id.to_s]
      @assistant.save!

      @ability = Ability.new @assistant_user
      @patient = create(:patient,:anesthetist_id => @anesthetist.id)


      form = create :form

      @unassigned_assessment = create(:assessment,anesthetist_id: @anesthetist.id.to_s,form: form)
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