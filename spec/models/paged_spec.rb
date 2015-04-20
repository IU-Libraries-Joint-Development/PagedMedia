require 'spec_helper'

describe Paged do
  
  let(:paged) { FactoryGirl.create :test_paged }
  let(:valid_paged) { FactoryGirl.build :paged }
  let(:unchecked_paged) { FactoryGirl.build :paged, :unchecked }

  describe "FactoryGirl" do
    specify "provides a valid object" do
      expect(valid_paged).to be_valid
    end
    describe "with :unchecked trait" do
      it "has skip_sibling_validation" do
        expect(unchecked_paged.skip_sibling_validation).to eq true
      end
    end
    describe "with :with_pages trait:" do
      specify "creates 5 pages by default" do
        test_paged = FactoryGirl.create :paged, :with_pages
	expect(Page.all.size).to eq 5
      end
      number_of_pages = 3
      specify "creates customizable number of pages: #{number_of_pages}" do
        test_paged = FactoryGirl.create :paged, :with_pages, number_of_pages: number_of_pages
	expect(Page.all.size).to eq number_of_pages
      end
    end
    describe "with :with_sections trait:" do
      specify "creates 3 sections by default" do
        test_paged = FactoryGirl.create :paged, :with_sections
	expect(Section.all.size).to eq 3
      end
      number_of_sections = 5
      specify "creates customizable number of sections: #{number_of_sections}" do
        test_paged = FactoryGirl.create :paged, :with_sections, number_of_sections: number_of_sections
	expect(Section.all.size).to eq number_of_sections
      end
    end
    describe "with :with_sections_with_pages trait:" do
      let!(:test_paged) { FactoryGirl.create :paged, :with_sections_with_pages }
      specify "creates 3 sections" do
        puts test_paged.list_descendents_recursive
        expect(Section.all.size).to eq 3
      end
      specify "creates 9 pages" do
        expect(Page.all.size).to eq 9
      end
    end
  end
  
  it "should have the specified datastreams" do
    # Check for descMetadata datastream
    expect(paged.datastreams.keys).to include("descMetadata")
    expect(paged.descMetadata).to be_kind_of PagedDescMetadata
    # Check for rightsMetadata datastream
    expect(paged.datastreams.keys).to include("rightsMetadata")
    expect(paged.rightsMetadata).to be_kind_of Hydra::Datastream::RightsMetadata
    expect(paged.pagedXML).to be_kind_of ActiveFedora::Datastream
  end

  it "should have the attributes of a Paged object" do
    expect(paged.type).to be_present
    expect(paged.title).to be_present
    expect(paged.creator).to be_present
    expect(paged.publisher).to be_present
    expect(paged.publisher_place).to be_present
    expect(paged.issued).to be_present
  end
  
  it "should have the attributes of a Paged object and support update_attributes" do
    attributes_hash = {
      "title" => "overwrite title",
      "creator" => "overwrite creator"
    }
    
    # This will attempt to use Fedora and will fail if not available during tests
    paged.update_attributes( attributes_hash )
    
    # These attributes are "unique" in the call to delegate, which causes the results to be singular
    expect(paged.title).to be == attributes_hash["title"]
    expect(paged.creator).to be == attributes_hash["creator"]
  end
  
  it "should be saved to Fedora" do
    # This will attempt to use Fedora and will fail if not available during tests
    expect(paged.save).to be_true
  end

  # Node mix-in shared examples

  # Node traits, specific to this class
  describe "#valid_parent_classes" do
    subject(:class_array) { paged.valid_parent_classes }
    specify "equals [Collection]" do
      expect(class_array.size).to eq 1
      expect(class_array).to include Collection
    end
  end
  
end
