# Example calls:
#   FactoryGirl.create(:paged)
#   FactoryGirl.create(:paged, :with_pages)
#   FactoryGirl.create(;paged, :newspaper)
#   FactoryGirl.create(:paged, :score, :with_score_pages)

FactoryGirl.define do
  
  #Create a paged object
  factory :paged, class: Paged do
    type "generic"
    title "Paged Object"
    creator "Factory Girl"
    publisher "Generic Publisher"
    issued Time.now 

    #Create a test paged object
    factory :test_paged do
      title "Test Paged Object"
    end

    # Create paged object with 5 pages
    trait :with_pages do
      after(:create) do |paged|
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
    
    # Create paged object with sample score pages
    trait :with_score_pages do
      after(:create) do |paged|
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
    
    #Create a newspaper
    trait :newspaper do
      type "newspaper"
      title "Test Newspaper"
    end

    #Create a score
    trait :score do
      type "score"
      title "Test Score"
    end

  end
end
