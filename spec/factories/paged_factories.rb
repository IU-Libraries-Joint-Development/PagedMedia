FactoryGirl.define do
  
  #Create a paged object
  factory :test_paged, class: Paged do
    title "Test Paged Object"
    creator "Factory Girl"
  end

end
