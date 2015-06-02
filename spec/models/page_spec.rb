# Copyright 2014 Indiana University

describe Page do

  let!(:page) { FactoryGirl.create :page, prev_sib: '', next_sib: '' }

  describe "FactoryGirl" do
    let(:valid_page) { FactoryGirl.build :page }
    let(:unchecked_page) { FactoryGirl.build :page, :unchecked }

    it "provides a valid page" do
      expect(valid_page).to be_valid
    end

    describe "with :unchecked trait" do

      it "has skip_linkage_validation" do
        expect(unchecked_page.skip_linkage_validation).to eq true
      end

    end

  end

  it "should have the specified datastreams" do
    # Check for descMetadata datastream
    # Check for pageImage datastream
    # Check for pageOCR datastream
    # Check for pageXML datastream
    expect(page.datastreams.keys).to include "pageXML"
    expect(page.pageXML).to be_kind_of ActiveFedora::Datastream
  end

  it "should have the specified attributes" do
    expect(page).to respond_to(:descMetadata)
    expect(page).to respond_to(:image_file)
    expect(page).to respond_to(:ocr_file)
    expect(page).to respond_to(:xml_file)
    expect(page).to respond_to(:logical_number)
    expect(page).to respond_to(:text)
    expect(page).to respond_to(:prev_sib)
    expect(page).to respond_to(:next_sib)
  end

  # Node mix-in shared examples

  # Node traits, specific to this class
  describe "#valid_parent_classes" do
    subject(:class_array) { page.valid_parent_classes }
    specify "equals [Paged, Section]" do
      expect(class_array.size).to eq 2
      expect(class_array).to include Paged
      expect(class_array).to include Section
    end
  end

end
