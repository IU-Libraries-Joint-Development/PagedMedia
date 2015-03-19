require 'yaml'

FactoryGirl.define do

  factory :collection, class: Collection do
    name "Factory Girl"

    trait :invalid do
      name nil
    end

  end
end
