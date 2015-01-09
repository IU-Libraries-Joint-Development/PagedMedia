require 'spec_helper'
 
  # To get the routes to work properly,
  # config.include Rails.application.routes.url_helpers
  # was added to RSpec.configure do |config|
  # in spec_helper.rb

  describe "facet search" do

    before(:all) do
      @test_newspaper = FactoryGirl.create :paged, :newspaper
      @test_score = FactoryGirl.create :paged, :score
    end

    context "from the main page" do
      before(:each) do
        visit root_path
      end
      it "should list type links" do
      	within('#facets'){expect(page).to have_link @test_newspaper.type}
      	within('#facets'){expect(page).to have_link @test_score.type}
      end
      it "should link to type-specific items" do
      	within('#facets'){click_link(@test_newspaper.type)}
        within('#documents'){expect(page).to have_content @test_newspaper.title}
        within('#documents'){expect(page).not_to have_content @test_score.title}
      end
    end

    context "from term search" do
      before(:each) do
        visit root_path
        click_button 'Search'
      end
      it "should filter to type-specific search results" do
        within('#documents'){expect(page).to have_content @test_newspaper.title}
        within('#documents'){expect(page).to have_content @test_score.title}
        within('#facets'){click_link(@test_newspaper.type)}
        within('#documents'){expect(page).to have_content @test_newspaper.title}
        within('#documents'){expect(page).not_to have_content @test_score.title}
      end
      it "should show unfiltered search results when filter is removed" do
        within('#facets'){click_link(@test_newspaper.type)}
        within('#appliedParams'){click_link "Remove constraint" }
        within('#documents'){expect(page).to have_content @test_newspaper.title}
        within('#documents'){expect(page).to have_content @test_score.title}
      end
    end

    after(:all) do
      @test_newspaper.delete
      @test_score.delete
    end

  end

  describe "term search" do
    
    before(:all) do
      @test_paged = FactoryGirl.create :paged
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

    context "search type" do
      it "should find records of type generic" do
        visit root_path
        select 'Type', from: 'search_field'
        fill_in 'q', with: @test_paged.type
        click_button 'Search'
        within('#documents'){expect(page).to have_content @test_paged.title}
      end
    end

    context "search results" do
      it "should have index numbers surrounded by span tag with an index_number class" do
        visit root_path
        click_button 'Search'
        within('#documents'){expect(page).to have_css('span.index_number')}
      end
    end
    
    after(:all) do
      @test_paged.delete
    end

  end

  describe 'browse' do
    it 'links to the list of Pageds when user selects Browse' do
      visit root_path
      click_button('Browse')
      expect(page).to have_table('listPageds')
    end
  end

  describe CatalogController do
    before(:all) do
      @newspaper_without_pages = FactoryGirl.create :paged, :newspaper
      @newspaper_with_pages = FactoryGirl.create :paged, :newspaper, :with_pages
    end

    describe "GET view" do
      let(:get_args) { {id: "SET_FOR_CONTEXT" } }
      let(:get_view) { get :view, **get_args }
      context "with no pages" do
        before(:each) do
          get_args[:id] = @newspaper_without_pages.id
          get_view
        end
        it "returns only paged object in @documents" do
          expect(assigns(:documents).size).to eq 1
          expect(assigns(:pageds).size).to eq 1
          expect(assigns(:pages).size).to eq 0
        end
      end
      context "with 5 pages" do
        before(:each) do
          get_args[:id] = @newspaper_with_pages.id
          get_view
        end
        it "returns paged object and pages in @documents" do
          expect(assigns(:documents).size).to eq 6
          expect(assigns(:pageds).size).to eq 1
          expect(assigns(:pages).size).to eq 5
        end
      end
      context "with invalid paged id" do
        before(:each) do
          get_args[:id] = "INVALID ID"
        end
        it "raises an error" do
          expect{ get_view }.to raise_error
        end
      end
    end

   after(:all) do
     @newspaper_without_pages.delete
     @newspaper_with_pages.delete
   end
  end
