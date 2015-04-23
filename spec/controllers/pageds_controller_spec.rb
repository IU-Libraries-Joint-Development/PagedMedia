require 'json'

describe PagedsController, type: :controller do
  let(:ordered_pages) { [1,2,3,4,5] }
  before(:each) do
    @test_paged = Paged.new
    @test_pages = []
    prev = nil
    5.times do |i|
      pid = (i+1).to_s
      @test_pages[i] = MockPage.new
      @test_pages[i].id = pid
      @test_pages[i].prev_sib = prev
      @test_pages[i-1].next_sib = pid if i > 0
      @test_paged.children << pid
      prev = pid
    end
  end

  describe '#index' do
    render_views
    before(:each) { get :index }
    it 'sets @pageds' do
      expect(assigns(:pageds)).to eq [test_paged]
    end
    it 'renders :index template' do
      expect(response).to render_template :index
    end
  end

  describe '#show' do
    render_views
    before(:each) { get :show, id: test_paged.pid }
    it 'sets @paged' do
      expect(assigns(:paged)).to eq test_paged
    end
    it 'renders :show template' do
      expect(response).to render_template :show
    end
  end

  describe '#new' do
    render_views
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
    render_views
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
      render_views
      let(:post_create) { post :create, paged: FactoryGirl.attributes_for(:paged, prev_sib: test_paged.pid) }
      it 'assigns an unpersisted @paged' do
        post_create
        expect(assigns(:paged)).to be_a Paged
        expect(assigns(:paged)).not_to be_persisted
      end
      it 'does not create a new object' do
        expect{ post_create }.not_to change(Paged, :count)
      end
      it 'renders the new template' do
        post_create
        expect(response).to render_template :new
      end
    end
  end

  describe '#update' do
    let!(:original_title) { test_paged.title }
    context 'with valid params' do
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
      render_views
      before(:each) { put :update, id: test_paged.id, paged: { title: test_paged.title + " updated", prev_sib: test_paged.id } }
      it 'does not update values' do
        expect(test_paged.title).to eq original_title
        test_paged.reload
        expect(test_paged.title).to eq original_title
      end
      it 'does not flash success' do
        expect(flash[:notice].to_s).not_to match(/success/i)
      end
      it 'renders the edit template' do
        expect(response).to render_template :edit
      end
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
#    before(:each) { patch :reorder, id: test_pid, reorder_submission: reorder_submission }

    context 'with no reorder values provided' do
      let(:test_pid) { test_paged.pid }
      let(:reorder_submission) { nil }

      it 'flashes "No change"' do
        patch :reorder, id: test_pid, reorder_submission: reorder_submission
        expect(flash[:notice]).to match(/No change/i)
      end

      it 'redirects to :edit' do
        expect(response).to redirect_to action: :edit
        patch :reorder, id: test_pid, reorder_submission: reorder_submission
      end
    end

    context 'with valid reorder values' do
      context 'with pages, only' do
        let(:test_pid) { test_paged.pid }
        let(:reorder_submission) { ordered_pages.reverse.map { |pid| { "id" => pid } }.to_json }

        it 'reorders pages' do
          test_paged.reload
          expect(test_paged.order_children[0]).to eq ordered_pages.reverse
        end

        it 'redirects to :edit' do
          patch :reorder, id: test_paged.pid, reorder_submission: reorder_submission
          expect(response).to redirect_to action: :edit
        end
      end

      context 'with sections and pages' do
        let!(:complex_paged) { FactoryGirl.create(:paged, :unchecked, :with_sections_with_pages) }
      	let!(:original_order) { complex_paged.order_child_objects[0].map { |section| { "id" => section.pid, "children" => section.order_children[0].map { |pid| { "id" => pid } } } } }
        let(:test_pid) { complex_paged.pid }

        context 'reordering sections' do
      	  let(:reorder_submission) { original_order.reverse.to_json }
	        it 'reorders sections' do
            complex_paged.reload
	          expect(complex_paged.order_children[0]).to eq original_order.map { |h| h["id"] }.reverse
      	  end
      	end

        context 'reparenting sections' do
          let(:reorder_submission) do
            [{ "id" => original_order[0]["id"], "children" => original_order[0]["children"] + [original_order[1]]},
             { "id" => original_order[2]["id"], "children" => original_order[2]["children"]}].to_json
          end

          it 'reparents section' do
            complex_paged.reload
            expect(complex_paged.order_child_objects[0].first.order_children[0].last).to eq original_order[1]["id"]
          end
        end

        context 'reordering pages' do
          let(:reorder_submission) { ordered_pages.reverse.join(',') }

          it 'reorders pages' do
            expect(Page).to receive(:find).at_least(:once) {|pid| @test_pages[pid.to_i-1]}
            allow(Paged).to receive(:find).and_return(@test_paged)
            allow_any_instance_of(Paged).to receive(:valid?).and_return(true)
            allow_any_instance_of(Paged).to receive(:save).and_return(true)
            allow_any_instance_of(Paged).to receive(:update_index)
            patch :reorder, id: 0, reorder_submission: reorder_submission
            # Check link order
            ['2','3','4','5',nil].each_with_index {|p,i| expect(@test_pages[i].prev_sib).to eq(p)}
            [nil,'1','2','3','4'].each_with_index {|p,i| expect(@test_pages[i].next_sib).to eq(p)}
          end
        end
      end

      context 'reparenting pages' do
        let(:reorder_array) do
          [{ "id" => original_order[0]["id"], "children" => original_order[0]["children"] - [original_order[0]["children"].last]},
           { "id" => original_order[0]["children"].last["id"]},
           { "id" => original_order[1]["id"], "children" => original_order[1]["children"]},
           { "id" => original_order[2]["id"], "children" => original_order[2]["children"]}]
        end
        let(:reorder_submission) { reorder_array.to_json }

        it 'reparents page' do
          complex_paged.reload
          expect(complex_paged.order_children[0]).to eq reorder_array.map { |h| h["id"] }
        end
      end
    end
  end

  describe '#bookreader' do
    render_views
    before(:each) { get :bookreader, id: test_paged.id }
    it 'assigns @paged' do
      expect(assigns(:paged)).to eq test_paged
    end
    it 'renders :bookreader template' do
      expect(response).to render_template :bookreader
    end
  end

end

# RSpec::Mocks just doesn't do what I need, so do it the jmockit way (sort of).
class MockPage < Page
  @my_id = nil
  @prev_sib = nil
  @next_sib = nil

  def pid
    id
  end

  def id
    @my_id
  end

  def id=(new_id)
    @my_id = new_id
  end

  def prev_sib
    @prev_sib
  end

  def prev_sib=(p)
    @prev_sib = p
  end

  def next_sib
    @next_sib
  end

  def next_sib=(n)
    @next_sib = n
  end

  def valid?
    true
  end

  def save(*)
    true
  end
end
