# Copyright 2014 Indiana University

require 'spec_helper'

describe Page do

  before(:each) { @page = Page.new }

  it "should have the specified datastreams" do
    # Check for descMetadata datastream
    # Check for pageImage datastream
    # Check for pageOCR datastream
    # Check for pageXML datastream
    @page.datastreams.keys.should include "pageXML"
    @page.pageXML.should be_kind_of ActiveFedora::Datastream
  end

  #FIXME: why do these 3 rspec tests fail, when they work in the console?
#  it { should respond_to(:descMetadata) }
  it { should respond_to(:image_file) }
  it { should respond_to(:ocr_file) }
  it { should respond_to(:xml_file) }

  it { should respond_to(:logical_number) }
  it { should respond_to(:text) }
  it { should respond_to(:prev_page) }
  it { should respond_to(:next_page) }

end
