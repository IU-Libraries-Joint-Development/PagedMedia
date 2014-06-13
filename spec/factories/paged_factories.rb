FactoryGirl.define do
  
  #Create a paged object
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
