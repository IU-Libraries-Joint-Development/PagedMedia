# Despite its name, this is a functional test of pageds_controller *and its supporting cast*.
describe 'Pageds features' do
  let!(:test_paged) { FactoryGirl.create :paged, :with_pages }
  let(:page3) { Page.find(test_paged.page_list[2][:id]) }
  let(:test_pageless) { FactoryGirl.create :paged }

  context "when pages are listed" do  
    specify "they should be ordered according to prev and next page ids" do
      visit paged_path(test_paged.pid)
      expect(page.body.index("Page 1")).to be < page.body.index("Page 2")
      expect(page.body.index("Page 2")).to be < page.body.index("Page 3")
      expect(page.body.index("Page 3")).to be < page.body.index("Page 4")
      expect(page.body.index("Page 4")).to be < page.body.index("Page 5")
    end
  end
  
  context "when more than one first page is found" do
    before(:each) do
      # Remove page 3's prev_sib
      page3.prev_sib = ''
      page3.skip_sibling_validation = true
      page3.save!(unchecked: true)
    end
    specify "an error message should display" do
      visit validate_paged_path(test_paged.pid)
      expect(page).to have_css('div.alert-error')
    end
  end

  context "when an infinite loop would occur " do
    before(:each) do
      # Point page 3's next_sib to itself
      page3.next_sib = page3.pid
      page3.skip_sibling_validation = true
      page3.save!(unchecked: true)
    end
    specify "an error message should display" do
      visit validate_paged_path(test_paged.pid)
      expect(page).to have_css('div.alert-error')
    end
  end
  
  context "when not all the pages are included in listing" do
    before(:each) do
      # Point page 3's next_sib to nothing
      page3.next_sib = ''
      page3.skip_sibling_validation = true
      page3.save!(unchecked: true)
    end
    specify "an error message should display" do
      visit validate_paged_path(test_paged.pid)
      expect(page).to have_css('div.alert-error')
    end
  end
  
  context "when no pages are included in listing" do
    specify "page should still display" do
      visit validate_paged_path(test_pageless.pid)
      expect(page).to have_content(test_pageless.title)
    end
  end

it 'stores a new XML datastream'

end
=begin
# Abortive attempt at testing the drag/drop page reordering interface.  This
# turns out to be really hard to do, because of JQuery weirdness.  After
# discussion, I think we agreed that this is better done as a controller
# test of some kind.
#
# This depends on https://github.com/mattheworiordan/jquery.simulate.drag-sortable.js
#
# I could not find a way to fetch the script from the application assets, so I
# just dropped it into my local webserver.  The author thinks serving it from
# the application is possible but gives no example.

feature 'User reorders pages', js: true do

  let!(:test_paged) { FactoryGirl.create(:paged, :with_pages) }

  scenario 'by dragging and dropping in the page order list' do
    visit paged_path(test_paged.pid)
    sortablePages = page.all(:xpath, "//ul[@id='sortable_pages']/li")
    puts 'sortablePages:'
    for i in 0..sortablePages.length-1 do p sortablePages[i] end
    puts 'test_paged.children:'
    for i in 0..test_paged.children.length-1 do p test_paged.children[i] end
    # find a likely page, drag it across another and drop it.
    #sortablePages[1].drag_to(sortablePages[0]) # doesn't work!
    puts 'sortablePages[0]:  ', sortablePages[0].native.id
    url = '"https://mhw.ulib.iupui.edu/~mwood/jquery.simulate.drag-sortable.js"' # FIXME don't depend on Mark's webserver
    function = "function() {$(\"li##{sortablePages[0][:id]}\").simulateDragSortable({ move: 1});}"
    script = "$.getScript(#{url}, #{function});"
    p script
    page.execute_script script
    test_paged.save

    test_paged.reload
    # check the page order list
    visit paged_path(test_paged.pid)
    sortablePages = page.all(:xpath, "//ul[@id='sortable_pages']/li")
    puts 'sortablePages:'
    for i in 0..sortablePages.length-1 do p sortablePages[i] end
    puts 'test_paged.children:'
    for i in 0..test_paged.children.length-1 do p test_paged.children[i] end
  end

end
=end
