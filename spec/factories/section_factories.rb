require 'yaml'

FactoryGirl.define do

  factory :section, class: Section do
    name "Factory Girl"

    trait :invalid do
      name nil
    end

  end
end
