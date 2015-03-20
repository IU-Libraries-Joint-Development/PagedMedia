require "spec_helper"

describe SectionsController do
  describe "routing" do

    describe "nested methods" do
      it "routes to #index" do
        get("/pageds/1/sections").should route_to("sections#index", paged_id: "1")
      end
  
      it "routes to #new" do
        get("/pageds/1/sections/new").should route_to("sections#new", paged_id: "1")
      end
  
      it "routes to #create" do
        post("/pageds/1/sections").should route_to("sections#create", paged_id: "1")
      end
    end

   describe "shallow methods" do
  
      it "routes to #show" do
        get("/sections/1").should route_to("sections#show", :id => "1")
      end
  
      it "routes to #edit" do
        get("/sections/1/edit").should route_to("sections#edit", :id => "1")
      end
  
      it "routes to #update" do
        put("/sections/1").should route_to("sections#update", :id => "1")
      end
  
      it "routes to #destroy" do
        delete("/sections/1").should route_to("sections#destroy", :id => "1")
      end
    end

  end
end
