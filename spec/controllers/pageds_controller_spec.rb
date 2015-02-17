require 'json'

describe PagedsController do
  render_views
  let!(:test_paged) { FactoryGirl.create(:paged, :with_pages) }

  describe '#index' do
    before(:each) { get :index }
    it 'sets @pageds' do
      expect(assigns(:pageds)).to eq [test_paged]
    end
    it 'renders :index template' do
      expect(response).to render_template :index
    end
  end

  describe '#show' do
    before(:each) { get :show, id: test_paged.id }
    it 'sets @paged' do
      expect(assigns(:paged)).to eq test_paged
    end
    it 'renders :show template' do
      expect(response).to render_template :show
    end
  end

  describe '#new' do
    before(:each) { get :new }
    it 'sets @paged' do
      expect(assigns(:paged)).to be_a_new Paged
      expect(assigns(:paged)).not_to be_persisted
    end
    it 'renders :new template' do
      expect(response).to render_template :new
    end
  end

  describe '#edit' do
    before(:each) { get :edit, id: test_paged.id }
    it 'sets @paged' do
      expect(assigns(:paged)).to eq test_paged
    end
    it 'renders :edit template' do
      expect(response).to render_template :edit
    end
  end

  describe '#create' do
    context 'with valid params' do
      let(:post_create) { post :create, paged: FactoryGirl.attributes_for(:paged) }
      it 'assigns @paged' do
        post_create
        expect(assigns(:paged)).to be_a Paged
        expect(assigns(:paged)).to be_persisted
      end
      it 'saves the new object' do
        expect{ post_create }.to change(Paged, :count).by(1)
      end
      it 'redirects to the object' do
        post_create
        expect(response).to redirect_to assigns(:paged)
      end
    end
    context 'with invalid params' do
      specify 'FIXME: untestable until invalid paged parameters determined'
    end
  end

  describe '#update' do
    context 'with valid params' do
      let!(:original_title) { test_paged.title }
      before(:each) { put :update, id: test_paged.id, paged: { title: test_paged.title + " updated" } }
      it 'assigns @paged' do
        expect(assigns(:paged)).to eq test_paged
      end
      it 'updates values' do
        expect(test_paged.title).to eq original_title
        test_paged.reload
        expect(test_paged.title).not_to eq original_title
      end
      it 'flashes success' do
        expect(flash[:notice]).to match(/success/i)
      end
      it 'redirects to updated paged' do
        expect(response).to redirect_to test_paged
      end
    end
    context 'with invalid params' do
      specify 'FIXME: untestable until invalid paged parameters determined'
    end
  end

  describe '#destroy' do
    let(:delete_destroy) { delete :destroy, id: test_paged.id }
    it 'destroys a Paged' do
      expect{ delete_destroy }.to change(Paged, :count).by(-1)
    end
    it 'redirects to pageds index' do
      delete_destroy
      expect(response).to redirect_to pageds_path
    end
  end

  describe '#pages' do
    let!(:ordered_pages) { test_paged.pages.sort { |a, b| a.logical_number <=> b.logical_number } }
    it 'should return pid and image ds uri given an index integer' do
      index = 1
      get :pages, id: test_paged.id, index: index
      parsed = JSON.parse response.body
      expect(parsed['id']).to eq ordered_pages[index].pid
      expect(parsed['index']).to eq index.to_s
      expect(parsed['ds_url']).to match(/#{ERB::Util.url_encode(ordered_pages[index].pid)}\/datastreams\/pageImage\/content$/)
    end
  end

  describe '#reorder' do
    context 'with no params provided' do
      specify 'user is notified in the flash' do
        patch :reorder, id: test_paged.id
        expect(flash[:notice]).to be_present
      end
    end

    context 'with valid params' do
      # This test looks a bit odd, because the order of pages in a Paged is
      # actually distributed across its children (the Pages) and is not found
      # anywhere in Paged.
      specify 'pages are reordered as given' do
        # List the pages
        my_pages = {}
        first_page = nil
        test_paged.pages.each do |page|
          first_page = page.pid if page.prev_page.nil?
          my_pages[page.pid] = page.next_page
        end

        # Discover the existing page order
        page_ids = []
        next_page = first_page
        loop do
          page_ids << next_page
          next_page = my_pages[next_page]
          break if next_page.nil?
        end

        # Rearrange the pages
        page_ids.insert(0, page_ids.slice!(1))
        patch :reorder, id: test_paged.id, reorder_submission: page_ids.join(',')

        # expect "saves the logical position of each of the pages from the list"
        # expect "calculates and saves previous and next siblings for each page"
        page_ids.each_index do |pageN|
          my_page = Page.find(page_ids[pageN])
          expect(my_page.prev_page).to eq(pageN-1 < 0 ? nil : page_ids[pageN-1])
          expect(my_page.next_page).to eq(pageN+1 > page_ids.length ? nil : page_ids[pageN+1])
        end

      end

    end
  end

  describe '#bookreader' do
    before(:each) { get :bookreader, id: test_paged.id }
    it 'assigns @paged' do
      expect(assigns(:paged)).to eq test_paged
    end
    it 'renders :bookreader template' do
      expect(response).to render_template :bookreader
    end
  end

end
