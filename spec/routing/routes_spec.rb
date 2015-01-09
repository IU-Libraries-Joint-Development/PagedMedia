require 'spec_helper'

describe "pageds" do
  specify "view action routes to catalog#view" do
    expect(get("/pageds/:id/view")).to route_to controller: "catalog", action: "view", id: ":id"
  end
end
