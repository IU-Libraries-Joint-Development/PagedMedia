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
        i = 0
        while i < 5 do
          page = create(:page, paged: paged, logical_number: "Page #{i + 1}")
          pages << page
          if i > 0
            page.prev_page = pages[i-1].pid
            page.save!
          end
          if i < 5
            prev_page = pages[i-1]
            prev_page.next_page = page.pid
            prev_page.save!
          end
          i += 1
        end
        # "Randomize" order of pages
        page_numbers = [3,4,5,1,2]
        page_numbers.each do |number|
          paged.pages[number - 1].save!
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
