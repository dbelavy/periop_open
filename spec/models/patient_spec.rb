require 'spec_helper'

describe Patient do
  describe "safe delete" do

  before(:each) do
    @patient = create(:patient)
    puts @patient.inspect
    @patient.delete
  end

    it "should delete patient" do
        expect(Patient.all.size).to eq 0
        expect(Patient.respond_to? :deleted).to eq true
        expect(Patient.deleted.first).to eq @patient
    end
  end
end
