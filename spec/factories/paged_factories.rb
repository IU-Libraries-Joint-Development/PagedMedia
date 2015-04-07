# Example calls:
#   FactoryGirl.create(:paged)
#   FactoryGirl.create(:paged, :with_pages)
#   FactoryGirl.create(;paged, :newspaper)
#   FactoryGirl.create(:paged, :score, :with_score_pages)
require 'yaml'

FactoryGirl.define do

  #Create a paged object
  factory :paged, class: Paged do
    type "generic"
    title "Paged Object"
    creator "Factory Girl"
    publisher "Generic Publisher"
    publisher_place "Metropolis"
    # FIXME Why couldn't we get Time.now through the RDF::DC validations?
    issued "2015-04-06"

    #Create a test paged object
    factory :test_paged do
      title "Test Paged Object"
    end

    # Create paged object with 5 pages
    trait :with_pages do
      after(:create) do |paged|
        pages = Array.new
        (0...5).each do |i|
          pages[i] = create(:page, :unchecked, parent: paged.pid, logical_number: "Page #{i + 1}", prev_sib: i.zero? ? nil : pages[i - 1].pid)
        end
        next_page = nil
        pages.reverse_each do |page|
          page.next_sib = next_page.pid if next_page
          page.skip_sibling_validation = true
          page.save!(unchecked: true)
          next_page = page
        end
        paged.reload
        paged.update_index
      end
    end

    # Create paged object with sample score pages
    trait :with_score_pages do
      with_pages
      after(:create) do |paged|
        pages = paged.children.sort { |a, b| Page.find(a).logical_number <=> Page.find(b).logical_number }
        (0...pages.size).each do |i|
          score_page = 'spec/fixtures/scores/bhr9405/bhr9405-1-' + (i + 1).to_s + '.jpg'
          pages[i].pageImage.content = File.open(Rails.root + score_page)
          pages[i].skip_sibling_validation = true
          pages[i].save!(unchecked: true)
          #FIXME: helpful?
          page.reload
        end
      end
    end

    # Does not use with_pages trait, as logic differs, and may be deprecated
    # Create paged object from ingest package with sample pages
    trait :package_with_pages do
      package
      after(:create) do |paged|
        # TODO The manifest file is set here but should be discovered by walking tree of package dirs
        manifest_file = "spec/fixtures/ingest/pmp/package1/manifest.yml"
        file_content = YAML.load_file(Rails.root + manifest_file)
        # TODO The pageds position of 0 is set here but an iterator would be processing across all instances
        #   of pageds found in the manifest file
        page_data = file_content["pageds"][0]["pages"]
        pages = Array.new
        (0...page_data.count).each do |i|
          pages[i] = create(:page, :unchecked, parent: paged, logical_number: page_data[i]["descMetadata"]["logical_number"].to_s, prev_sib: i.zero? ? nil : pages[i - 1].pid, text: page_data[i]["descMetadata"]["text"].to_s, page_struct: page_data[i]["descMetadata"]["page_struct"])
          package_page =  'spec/fixtures/ingest/pmp/package1/' + 'content/' + page_data[i]["content"]["pageImage"]
          pages[i].pageImage.content = File.open(Rails.root + package_page)
        end
        next_page = nil
        pages.reverse_each do |page|
          page.next_sib = next_page.pid if next_page
          page.skip_sibling_validation = true
          page.save!(unchecked: true)
          next_page = page
        end
        paged.reload
        paged.update_index
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

    #Create from package
    trait :package do
      # TODO The manifest file is set here but should be discovered by walking tree of package dirs
      manifest_file = "spec/fixtures/ingest/pmp/package1/manifest.yml"
      file_content = YAML.load_file(Rails.root + manifest_file)
      # TODO The pageds position of 0 is set here but an iterator would be processing across all instances
      #   of pageds found in the manifest file
      title file_content["pageds"][0]["descMetadata"]["title"]
      creator file_content["pageds"][0]["descMetadata"]["creator"]
      type file_content["pageds"][0]["descMetadata"]["type"]
      publisher file_content["pageds"][0]["descMetadata"]["publisher"]
      publisher_place file_content["pageds"][0]["descMetadata"]["publisher_place"]
      paged_struct file_content["pageds"][0]["descMetadata"]["paged_struct"]
    end

  end
end
