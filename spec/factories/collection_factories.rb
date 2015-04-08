require 'yaml'

FactoryGirl.define do

  factory :collection, class: Collection do
    name "Factory Girl"

    trait :invalid do
      name nil
    end

    trait :unchecked do
      skip_sibling_validation true
    end

  end
end
