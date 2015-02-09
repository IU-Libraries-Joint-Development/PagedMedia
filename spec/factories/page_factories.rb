FactoryGirl.define do
  
  #Create a page object
  factory :page, class: Page do
    logical_number "Page 1"

    trait :unchecked do
      skip_sibling_validation true
    end
  end
  
end