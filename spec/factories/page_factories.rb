FactoryGirl.define do
  
  #Create a page object
  factory :page, class: Page do
    logical_number "Page 1"
    prev_page ""
    next_page ""
  end
  
end