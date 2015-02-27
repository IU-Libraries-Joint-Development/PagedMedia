# Copyright 2014 Indiana University

describe Page do

  let!(:paged) { FactoryGirl.create :test_paged }
  let!(:page) { FactoryGirl.create :page, prev_page: '', next_page: '' }

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
    expect(page).to respond_to(:prev_page)
    expect(page).to respond_to(:next_page)
  end

  describe 'enforces linkage rules:' do

    it 'adds itself to its Paged' do
      page.paged = paged
      page.save
      paged.reload # paged didn't see page linkage yet
      expect(paged.pages.size).to eq 1
    end

    it 'must have no siblings if it is the only one in this Paged' do
      page.paged = paged
      page.prev_page = 'too:many'
      expect(page.save).to be_false
    end

    it 'must have one or both siblings if it is not the only one in this Paged' do
      page.prev_page = ''
      page.logical_number = '1'
      page.paged = paged
      expect(page.save).to be_true
      paged.save

      page2 = FactoryGirl.create(:page, logical_number: '2', prev_page: '', next_page: '')
      paged.reload
      page2.paged = paged
      expect(page2.save).to be_false
    end

    it 'links itself between its siblings when saved' do
      page1, page2, page3 = make_a_book

      # page1, page2, page3 should now be linked in that order
      page1.reload
      page2.reload
      page3.reload
      expect(page1.prev_page).to be_empty
      expect(page1.next_page).to eql page2.pid
      expect(page2.prev_page).to eql page1.pid
      expect(page2.next_page).to eql page3.pid
      expect(page3.prev_page).to eql page2.pid
      expect(page3.next_page).to be_empty
    end

    it 'unlinks itself and links its siblings when deleted' do
      page1, page2, page3 = make_a_book

      page2.delete

      page1.reload
      expect(page1.prev_page).to be_empty
      expect(page1.next_page).to eql(page3.pid)

      page3.reload
      expect(page3.prev_page).to eql(page1.pid)
      expect(page3.next_page).to be_empty
    end

  end

  # Populate paged with three linked pages, and return references to them.
  def make_a_book
    # First page, can have no siblings
    page1 = FactoryGirl.create(:page, logical_number: '1', prev_page: '', next_page: '')
    page1.paged = paged
    page1.save!
    paged.save!

    # Second page, must have at least one sibling
    page3 = FactoryGirl.create(:page, logical_number: '3', next_page: '')
    page1.reload
    page3.prev_page = page1.pid
    paged.reload
    page3.paged = paged
    page3.save!
    paged.save!

    # Third page, inserts itself between first and second
    page2 = FactoryGirl.create(:page, logical_number: '2')
    page1.reload
    page2.prev_page = page1.pid # follows first page
    page3.reload
    page2.next_page = page3.pid # precedes second page
    paged.reload
    page2.paged = paged
    page2.save!

    return [ page1, page2, page3 ]
  end

end
