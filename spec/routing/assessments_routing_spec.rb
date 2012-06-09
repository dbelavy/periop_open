require "spec_helper"

describe AssessmentsController do
  describe "routing" do

    it "routes to #index" do
      get("/assessments").should route_to("assessments#index")
    end

    it "routes to #new" do
      get("/assessments/new").should route_to("assessments#new")
    end

    it "routes to #show" do
      get("/assessments/1").should route_to("assessments#show", :id => "1")
    end

    it "routes to #edit" do
      get("/assessments/1/edit").should route_to("assessments#edit", :id => "1")
    end

    it "routes to #create" do
      post("/assessments").should route_to("assessments#create")
    end

    it "routes to #update" do
      put("/assessments/1").should route_to("assessments#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/assessments/1").should route_to("assessments#destroy", :id => "1")
    end

  end
end
