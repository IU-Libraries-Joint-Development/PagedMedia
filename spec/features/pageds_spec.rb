describe 'For page listing' do
  let!(:test_paged) { FactoryGirl.create :paged, :with_pages }
  let(:page3) { test_paged.pages.sort { |a, b| a.logical_number <=> b.logical_number }[2] } 

  context "when pages are listed" do  
    specify "they should be ordered according to prev and next page ids" do
      visit pageds_path + '/' + test_paged.pid
      page.body.index("Page 1").should < page.body.index("Page 2")
      page.body.index("Page 2").should < page.body.index("Page 3")
      page.body.index("Page 3").should < page.body.index("Page 4")
      page.body.index("Page 4").should < page.body.index("Page 5")
    end
  end
  
  context "when more than one first page is found" do
    before(:each) do
      # Remove page 3's prev_page
      page3.prev_page = ''
      page3.skip_sibling_validation = true
      page3.save!(unchecked: true)
    end
    specify "an error message should display" do
      visit pageds_path + '/' + test_paged.pid
      expect(page).to have_css('div.alert-error')
    end
  end

  context "when a infinite loop would occur " do
    before(:each) do
      # Point page 3's next_page to itself
      page3.next_page = page3.pid
      page3.skip_sibling_validation = true
      page3.save!(unchecked: true)
    end
    specify "an error message should display" do
      visit pageds_path + '/' + test_paged.pid
      expect(page).to have_css('div.alert-error')
    end
  end
  
  context "when not all the pages are included in listing" do
    before(:each) do
      # Point page 3's next_page to nothing
      page3.next_page = ''
      page3.skip_sibling_validation = true
      page3.save!(unchecked: true)
    end
    specify "an error message should display" do
      visit pageds_path + '/' + test_paged.pid
      expect(page).to have_css('div.alert-error')
    end
  end

it 'stores a new XML datastream'

end

describe 'For page reordering' do

  let!(:test_paged) { FactoryGirl.create(:paged, :with_pages) }

  context "when pages are reordered" do  
    it "should respond to reorder"
    it "should accept a list of pages that need to have their order reset" 
    it "should save the logical position of each of the pages from the list"
    it "should calculate and save previous and next siblings for each page"
  end

end
