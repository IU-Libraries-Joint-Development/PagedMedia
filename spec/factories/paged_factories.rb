FactoryGirl.define do
  
  #Create a paged object
  factory :paged, class: Paged do
    title "Paged Object"
    creator "Factory Girl"
    type "generic"
    
    factory :paged_with_pages do
      after(:create) do |paged|
        # Create paged object with 5 pages
        pages = Array.new
        pages[0] = create(:page, paged: paged, logical_number: "Page 1")
        paged.reload
        i = 1
        while i < 5 do
          pages[i] = create(:page, paged: paged, logical_number: "Page #{i + 1}", prev_page: pages[i - 1].pid)
          paged.reload
          i += 1
        end
      end
    end
    
  end
  
  #Create a test paged object
  factory :test_paged, class: Paged do
    title "Test Paged Object"
    creator "Factory Girl"
    type "generic"
  end

  #Create a newspaper
  factory :test_newspaper, class: Paged do
    title "Test Newspaper"
    creator "Factory Girl"
    type "newspaper"
  end

  #Create a score
  factory :test_score, class: Paged do
    title "Test Score"
    creator "Factory Girl"
    type "score"
  end

end
