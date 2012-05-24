require 'spec_helper'

describe "authorisation checks" do


  describe "patient should't see other patient" do
    
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get questions_path
      response.status.should be(200)
    end
  end
end
