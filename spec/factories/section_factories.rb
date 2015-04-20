require 'yaml'


FactoryGirl.define do

  factory :section, class: Section do
    name "Factory Girl"

    trait :invalid do
      name nil
    end

    trait :unchecked do
      skip_sibling_validation true
    end

    # Create child pages, 5 by default
    trait :with_pages do
      ignore do
        number_of_pages 5
      end
      after(:create) do |section, evaluator|
        FactoryHelpers::NodeHelpers.create_children(section, Page, evaluator.number_of_pages)
      end
    end

  end
end
