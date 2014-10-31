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
    title "Fontane Di Roma"
    creator "Ottorino Respighi"
    type "score"
    factory :score_with_pages do
      after(:create) do |paged|
        # Create a score with 10 pages
        pages = Array.new
        pages[0] = create(:page, paged: paged, logical_number: "Page 1")
        paged.reload
        i = 1
        while i < 5 do
          pages[i] = create(:page, paged: paged, logical_number: "Page #{i + 1}", prev_page: pages[i - 1].pid)
          paged.reload
          i += 1
        end
        pages.each do |page|
          page.reload
          p pages.index(page)
          p page.pid
          p page.logical_number
          score_page =  'spec/fixtures/scores/bhr9405/bhr9405-1-' + (pages.index(page)+1).to_s + '.jpg'
          p score_page
          page.pageImage.content = File.open(Rails.root + score_page)
          page.save
        end
      end
    end
  end

end
