describe "Catalog features" do

  describe "facet search" do
    let!(:test_newspaper) { FactoryGirl.create :paged, :newspaper }
    let!(:test_score) { FactoryGirl.create :paged, :score }

    context "from the main page" do
      before(:each) do
        visit root_path
      end
      it "should list type links" do
      	within('#facets'){expect(page).to have_link test_newspaper.type}
      	within('#facets'){expect(page).to have_link test_score.type}
      end
      it "should link to type-specific items" do
      	within('#facets'){click_link(test_newspaper.type)}
        within('#documents'){expect(page).to have_content test_newspaper.title}
        within('#documents'){expect(page).not_to have_content test_score.title}
      end
    end

    context "from term search" do
      before(:each) do
        visit root_path
        click_button 'Search'
      end
      it "should filter to type-specific search results" do
        within('#documents'){expect(page).to have_content test_newspaper.title}
        within('#documents'){expect(page).to have_content test_score.title}
        within('#facets'){click_link(test_newspaper.type)}
        within('#documents'){expect(page).to have_content test_newspaper.title}
        within('#documents'){expect(page).not_to have_content test_score.title}
      end
      it "should show unfiltered search results when filter is removed" do
        within('#facets'){click_link(test_newspaper.type)}
        within('#appliedParams'){click_link "Remove constraint" }
        within('#documents'){expect(page).to have_content test_newspaper.title}
        within('#documents'){expect(page).to have_content test_score.title}
      end
    end

  end

  describe "term search" do
    let!(:test_paged) { FactoryGirl.create :paged }
    
    context "searching everything" do
      it "should find records" do
        visit root_path
        click_button 'Search'
        within('#documents'){expect(page).to have_content test_paged.title}
      end
    end    
    context "search titles" do
      it "should find records" do
        visit root_path
        select 'Title', from: 'search_field'
        fill_in 'q', with: test_paged.title
        click_button 'Search'
        within('#documents'){expect(page).to have_content test_paged.title}
      end
    end
    context "search creator" do
      it "should find records" do
        visit root_path
        select 'Creator', from: 'search_field'
        fill_in 'q', with: test_paged.creator
        click_button 'Search'
        within('#documents'){expect(page).to have_content test_paged.title}
      end
    end

    context "search type" do
      it "should find records of type generic" do
        visit root_path
        select 'Type', from: 'search_field'
        fill_in 'q', with: test_paged.type
        click_button 'Search'
        within('#documents'){expect(page).to have_content test_paged.title}
      end
    end

    context "search results" do
      it "should have index numbers surrounded by span tag with an index_number class" do
        visit root_path
        click_button 'Search'
        within('#documents'){expect(page).to have_css('span.index_number')}
      end
    end
    
  end

  describe 'browse' do
    it 'links to the list of Pageds when user selects Browse' do
      visit root_path
      click_on('Browse')
      expect(page).to have_table('listPageds')
    end
  end

end
