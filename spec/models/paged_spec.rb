require 'spec_helper'

describe Paged do
  
  before(:each) do
    # This gives you a test Paged object that can be used in any of the tests
    @paged = Paged.new
  end
  
  it "should have the specified datastreams" do
    # Check for descMetadata datastream
    @paged.datastreams.keys.should include("descMetadata")
    @paged.descMetadata.should be_kind_of PagedMetadataOaiDc
    # Check for rightsMetadata datastream
    @paged.datastreams.keys.should include("rightsMetadata")
    @paged.rightsMetadata.should be_kind_of Hydra::Datastream::RightsMetadata
  end
  
  it "should have the attributes of a Paged object and support update_attributes" do
    attributes_hash = {
      "title" => "All the Awesome you can Handle",
      "creator" => "I. R. Awesome"
    }
    
    # This will attempt to use Fedora and will fail if not available during tests
    @paged.update_attributes( attributes_hash )
    
    # These attributes are "unique" in the call to delegate, which causes the results to be singular
    @paged.title.should == attributes_hash["title"]
    @paged.creator.should == attributes_hash["creator"]
  end
  
  it "should be saved to Fedora and indexed to SOLR" do
    # This will attempt to use Fedora and will fail if not available during tests
    @paged.save.should be_true
    @paged.update_index.should be_true
  end

  
end