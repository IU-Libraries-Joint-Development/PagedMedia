# Copyright 2014 Indiana University

require 'spec_helper'

describe Page do

  before(:all) do
    @paged = FactoryGirl.create :test_paged
    @paged.save
  end

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
      pending 'commented'
      empty @paged

      @page.paged = @paged
      @page.save
      @paged.reload # paged didn't see page linkage yet
      expect(@paged.pages.size).to eq 1

      empty @paged
    end

    it 'must have no siblings if it is the only one in this Paged' do
      pending 'commented'
      empty @paged

      @page.paged = @paged
      @page.prev_page = 'too:many'
      expect(@page.save).to be_false

      empty @paged
    end

    it 'must have one or both siblings if it is not the only one in this Paged' do
      empty @paged

      @page.prev_page = nil
      @page.logical_number = '1'
      @page.paged = @paged
      expect(@page.save).to be_true
      @paged.save

      page2 = Page.new(logical_number: '2')
      @paged.reload
      page2.paged = @paged
      expect(page2.save).to be_false

      empty @paged
    end

    it 'links itself between its siblings when saved' do
      pending 'commented'
      empty @paged

      page1, page2, page3 = make_a_book

      # page1, page2, page3 should now be linked in that order
      page1.reload
      page2.reload
      page3.reload
      expect(page1.prev_page).to be_nil
      expect(page1.next_page).to eql page2.pid
      expect(page2.prev_page).to eql page1.pid
      expect(page2.next_page).to eql page3.pid
      expect(page3.prev_page).to eql page2.pid
      expect(page3.next_page).to be_nil

      empty @paged
    end

    it 'unlinks itself and links its siblings when deleted' do
      empty @paged

      page1, page2, page3 = make_a_book
      puts page1.inspect
      puts page2.inspect
      puts page3.inspect

      page2.delete

      page1.reload
      expect(page1.prev_page).to be_nil
      expect(page1.next_page).to eql(page3.pid)

      page3.reload
      expect(page3.prev_page).to eql(page1.pid)
      expect(page3.next_page).to be_nil

      empty @paged
    end

  end

  # Populate @paged with three linked pages, and return references to them.
  def make_a_book
    # First page, can have no siblings
    page1 = Page.new(logical_number: '1')
    page1.paged = @paged
    page1.save!
    @paged.save!

    # Second page, must have at least one sibling
    page3 = Page.new(logical_number: '3')
    page1.reload
    page3.prev_page = page1.pid
    @paged.reload
    page3.paged = @paged
    page3.save!
    @paged.save!

    # Third page, inserts itself between first and second
    page2 = Page.new(logical_number: '2')
    page1.reload
    page2.prev_page = page1.pid # follows first page
    page3.reload
    page2.next_page = page3.pid # precedes second page
    @paged.reload
    page2.paged = @paged
    page2.save!

    return [ page1, page2, page3 ]
  end

end
