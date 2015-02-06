require 'spec_helper'

describe Paged do
  
  let(:paged) { FactoryGirl.create :test_paged }
  
  it "should have the specified datastreams" do
    # Check for descMetadata datastream
    paged.datastreams.keys.should include("descMetadata")
    paged.descMetadata.should be_kind_of PagedMetadataOaiDc
    # Check for rightsMetadata datastream
    paged.datastreams.keys.should include("rightsMetadata")
    paged.rightsMetadata.should be_kind_of Hydra::Datastream::RightsMetadata
    paged.pagedXML.should be_kind_of ActiveFedora::Datastream
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
    paged.title.should == attributes_hash["title"]
    paged.creator.should == attributes_hash["creator"]
  end
  
  it "should be saved to Fedora" do
    # This will attempt to use Fedora and will fail if not available during tests
    paged.save.should be_true
  end
  
end
