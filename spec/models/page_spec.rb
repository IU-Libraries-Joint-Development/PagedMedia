# Copyright 2014 Indiana University

require 'spec_helper'

describe Page do

  before(:all)  { @paged = FactoryGirl.create :test_paged; @paged.save }
  before(:each) { @page = Page.new }

  after(:all) do
    # Clean up Fedora debris
    empty @paged
    @paged.delete
  end

  def empty(paged)
    # Clean up Fedora debris
    paged.reload
    paged.pages.each {|page| page.delete}
    paged.reload # delete fails if in-memory Paged still knows deleted Pages
  end

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

  describe 'enforces linkage rules:' do

    it 'adds itself to its Paged' do
      empty @paged

      @page.paged = @paged
      @page.save
      @paged.reload # paged didn't see page linkage yet
      expect(@paged.pages.size).to eq 1

      empty @paged
    end

    it 'must have no siblings if it is the only one in this Paged' do
      empty @paged

      @page.paged = @paged
      @page.prev_page = 'too:many'
      expect(@page.save).to be_false

      empty @paged
    end

    it 'must have one or both siblings if it is not the only one in this Paged' do
      empty @paged

      @page.prev_page = nil
      @page.paged = @paged
      expect(@page.save).to be_true
      @paged.reload

      page2 = Page.new
      page2.paged = @paged
      expect(page2.save).to be_false

      empty @paged
    end

    it 'links itself between its siblings when saved'

    it 'unlinks itself and links its siblings when deleted'

  end

end
