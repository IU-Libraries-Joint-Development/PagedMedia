require 'spec_helper'
 
describe CatalogController do
  before(:all) do
    @newspaper_without_pages = FactoryGirl.create :paged, :newspaper
    @newspaper_with_pages = FactoryGirl.create :paged, :newspaper, :with_pages
  end

  describe "GET view" do
    let(:get_args) { {id: "SET_FOR_CONTEXT" } }
    let(:get_view) { get :view, **get_args }
    context "with no pages" do
      before(:each) do
        get_args[:id] = @newspaper_without_pages.id
        get_view
      end
      it "returns only paged object in @document_list" do
        expect(assigns(:document_list).size).to eq 1
      end
    end
    context "with 5 pages" do
      before(:each) do
        get_args[:id] = @newspaper_with_pages.id
        get_view
      end
      it "returns paged object and pages in @document_list" do
        expect(assigns(:document_list).size).to eq 6
      end
    end
    context "with invalid paged id" do
      before(:each) do
        get_args[:id] = "INVALID ID"
      end
      it "returns no objects in @document_list" do
        expect(assigns(:document_list).to_a.size).to eq 0
      end
    end
  end

 after(:all) do
   @newspaper_without_pages.delete
   @newspaper_with_pages.pages.each { |page| page.delete }
   @newspaper_with_pages.delete
 end

end
