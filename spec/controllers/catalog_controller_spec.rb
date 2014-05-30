require 'spec_helper'
 
  # To get the routes to work properly,
  # config.include Rails.application.routes.url_helpers
  # was added to RSpec.configure do |config|
  # in spec_helper.rb
 
  describe "term search" do
    
    before(:all) do
      @test_paged = FactoryGirl.create :test_paged 
    end
      
    context "searching everything" do
      it "should find records" do
        visit root_path
        click_button 'Search'
        within('#documents'){expect(page).to have_content @test_paged.title}
      end
    end    
    context "search titles" do
      it "should find records" do
        visit root_path
        select 'Title', from: 'search_field'
        fill_in 'q', with: @test_paged.title
        click_button 'Search'
        within('#documents'){expect(page).to have_content @test_paged.title}
      end
    end
    context "search creator" do
      it "should find records" do
        visit root_path
        select 'Creator', from: 'search_field'
        fill_in 'q', with: @test_paged.creator
        click_button 'Search'
        within('#documents'){expect(page).to have_content @test_paged.title}
      end
    end
    
    after(:all) do
      @test_paged.delete
    end

end