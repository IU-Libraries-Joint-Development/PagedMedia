require 'json'

describe PagedsController do
  render_views
  let!(:test_paged) { FactoryGirl.create(:paged, :with_pages) }
  let(:ordered_pages) { test_paged.order_children[0] }

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
    before(:each) { get :show, id: test_paged.pid }
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
    before(:each) { get :edit, id: test_paged.pid }
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
      pending '(untestable until invalid paged parameters exist)'
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
      pending '(untestable until invalid paged parameters exist)'
    end
  end

  describe '#destroy' do
    context 'when a Paged has no children' do
      let!(:empty_paged) { FactoryGirl.create(:paged) }
      let(:delete_destroy) { delete :destroy, id: empty_paged.pid }
      it 'destroys a Paged' do
        expect{ delete_destroy }.to change(Paged, :count).by(-1)
      end
      it 'redirects to pageds index' do
        delete_destroy
        expect(response).to redirect_to pageds_path
      end
    end
    context 'when a Paged has children' do
      it 'raises an exception' do
        expect{ delete :destroy, id: test_paged.pid }.to raise_error(OrphanError)
      end
    end
  end

  describe '#pages' do
    it 'should return pid and image ds uri given an index integer' do
      index = 1
      get :pages, id: test_paged.pid, index: index
      parsed = JSON.parse response.body
      expect(parsed['id']).to eq ordered_pages[index]
      expect(parsed['index']).to eq index.to_s
      expect(parsed['ds_url']).to match(/#{ERB::Util.url_encode(ordered_pages[index])}\/datastreams\/pageImage\/content$/)
    end
  end

  describe '#reorder' do
    before(:each) { patch :reorder, id: test_paged.pid, reorder_submission: reorder_submission }
    context 'with no reorder values provided' do
      let(:reorder_submission) { nil }
      it 'flashes "No change"' do
        expect(flash[:notice]).to match(/No change/i)
      end
      it 'redirects to :show' do
        expect(response).to redirect_to action: :show
      end
    end
    context 'with valid reorder values' do
      let(:reorder_submission) { ordered_pages.reverse.join(',') }
      it 'reorders pages' do
        expect(test_paged.order_children[0]).to eq ordered_pages.reverse
      end
      it 'redirects to :show' do
        expect(response).to redirect_to action: :show
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
