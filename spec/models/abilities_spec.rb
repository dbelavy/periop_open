require 'rspec'
require "cancan/matchers"

describe "abilities" do

  context "when user is an assistant" do
    before :each do
      @anesthetist = create(:professional_user)
      @assistant = create(:professional_user)
      @assistant.professional[:shared_professionals_ids] = [@anesthetist.professional.id]
      @assistant.professional.save!
      @ability = Ability.new @assistant
      @patient = create(:patient,:anesthetist_id => @anesthetist.professional.id)
    end

    it "have access to " do
      @assistant.professional.has_access_to.should eq([@anesthetist.professional.id])
    end
    it "able to see anesthtist patients" do
      @ability.should be_able_to(:read,@patient)
    end

  end
end