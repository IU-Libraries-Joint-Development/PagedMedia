require "spec_helper"

describe SectionsController do
  describe "routing" do

    describe "optionally nested methods" do

      describe "routes to #index" do
        specify "for a paged" do
          get("/pageds/1/sections").should route_to("sections#index", paged_id: "1")
        end
        specify "for all sections" do
          get("/sections").should route_to("sections#index")
        end
      end
  
      describe "routes to #new" do
        specify "for a paged" do
          get("/pageds/1/sections/new").should route_to("sections#new", paged_id: "1")
        end
        specify "for all sections" do
          get("/sections/new").should route_to("sections#new")
        end
      end
  
      describe "routes to #create" do
        specify "for a paged" do
          post("/pageds/1/sections").should route_to("sections#create", paged_id: "1")
        end
        specify "for all sections" do
          post("/sections").should route_to("sections#create")
        end
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
