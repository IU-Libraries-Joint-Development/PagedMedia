# Copyright 2014, 2015 Indiana University

require 'json'
require 'helpers/mock_page.rb'
require 'helpers/mock_paged.rb'
require 'helpers/mock_solr_service.rb'
include ModelMocks
include ServiceMocks

describe PagedsController, type: :controller do
  let(:ordered_pages) { ['1', '2', '3', '4', '5'] }
  before(:each) do
    @test_paged = MockPaged.new

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

    @mock_solr_service = MockSolrService.instance
    indexed = []
    @test_pages.each do |page|
      indexed << {
        'id' => page.id,
        'ds_url' => page.id + '/datastreams/pageImage/content',
        'logical_number' => page.id
        }
    end
    @mock_solr_service.index = indexed
  end

  describe '#index' do

    it 'sets @pageds' do
      allow(Paged).to receive(:all).and_return(MockPaged.all)

      get :index
      expect(assigns(:pageds)).to eq MockPaged.all
    end
    it 'renders :index template' do
      allow(Paged).to receive(:all).and_return(MockPaged.all)

      get :index
      expect(response).to render_template :index
    end
  end

  describe '#show' do

    it 'sets @paged' do
      expect(Paged).to receive(:find).and_return(@test_paged)
      allow(ActiveFedora::SolrService).to receive(:instance).and_return(@mock_solr_service)

      get :show, id: @test_paged.pid
      expect(assigns(:paged)).to eq @test_paged
    end

    it 'renders :show template' do
      expect(Paged).to receive(:find).and_return(@test_paged)
      allow(ActiveFedora::SolrService).to receive(:instance).and_return(@mock_solr_service)

      get :show, id: @test_paged.pid
      expect(response).to render_template :show
    end
  end

  describe '#new' do

    it 'sets @paged' do
      expect(Paged).to receive(:new).and_return(@test_paged)

      get :new
      expect(assigns(:paged)).to be_a_new MockPaged
      expect(assigns(:paged)).not_to be_persisted
    end

    it 'renders :new template' do
      allow(Paged).to receive(:new).and_return(@test_paged)

      get :new
      expect(response).to render_template :new
    end
  end

  describe '#edit' do

    it 'sets @paged' do
      expect(Paged).to receive(:find).and_return(@test_paged)
      allow(ActiveFedora::SolrService).to receive(:instance).and_return(@mock_solr_service)

      get :edit, id: @test_paged.pid
      expect(assigns(:paged)).to eq @test_paged
    end

    it 'renders :edit template' do
      expect(Paged).to receive(:find).and_return(@test_paged)
      allow(ActiveFedora::SolrService).to receive(:instance).and_return(@mock_solr_service)

      get :edit, id: @test_paged.pid

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
      let(:post_create) { post :create, paged: FactoryGirl.attributes_for(:paged, prev_sib: @test_paged.pid) }

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
    let!(:original_title) { @test_paged.title }

    context 'with valid params' do

      it 'assigns @paged' do
        allow(Paged).to receive(:find).and_return(@test_paged)
        put :update, id: @test_paged.id, paged: { title: @test_paged.title + " updated" }
        expect(assigns(:paged)).to eq @test_paged
      end

      it 'updates values' do
        expect(@test_paged.title).to eq original_title
        allow(Paged).to receive(:find).and_return(@test_paged)
        expect(@test_paged).to receive(:update).with({ 'title' => @test_paged.title + ' updated'})
        put :update, id: @test_paged.id, paged: { title: @test_paged.title + ' updated' }
      end

      it 'flashes success' do
        allow(Paged).to receive(:find).and_return(@test_paged)
        put :update, id: @test_paged.id, paged: { title: @test_paged.title + " updated" }
        expect(flash[:notice]).to match(/success/i)
      end

      it 'redirects to updated paged' do
        allow(Paged).to receive(:find).and_return(@test_paged)
        put :update, id: @test_paged.id, paged: { title: @test_paged.title + " updated" }
        expect(response).to redirect_to @test_paged
      end
    end

    context 'with invalid params' do

      it 'does not update values' do
        expect(@test_paged.title).to eq original_title
        allow(Paged).to receive(:find).and_return(@test_paged)
        put :update, id: @test_paged.id, paged: { title: @test_paged.title + " updated", prev_sib: @test_paged.id }
        expect(@test_paged.title).to eq original_title
      end

      it 'does not flash success' do
        allow(Paged).to receive(:find).and_return(@test_paged)
        expect(@test_paged).to receive(:update).and_return(false)
        put :update, id: @test_paged.id, paged: { title: @test_paged.title + " updated", prev_sib: @test_paged.id }
        expect(flash[:notice].to_s).not_to match(/success/i)
      end

      it 'renders the edit template' do
        allow(Paged).to receive(:find).and_return(@test_paged)
        expect(@test_paged).to receive(:update).and_return(false)
        put :update, id: @test_paged.id, paged: { title: @test_paged.title + " updated", prev_sib: @test_paged.id }
        expect(response).to render_template :edit
      end
    end
  end

  describe '#destroy' do

    context 'when a Paged has no children' do

      it 'destroys a Paged' do
        allow(Paged).to receive(:find).and_return(@test_paged)
        expect{ delete :destroy, id: @test_paged.id }.to change(MockPaged, :count).by(-1)
      end

      it 'redirects to pageds index' do
        allow(Paged).to receive(:find).and_return(@test_paged)
        expect(@test_paged).to receive(:destroy)
        delete :destroy, id: @test_paged.id
        expect(response).to redirect_to pageds_path
      end
    end

    context 'when a Paged has children' do

      it 'raises an exception' do
        allow(Paged).to receive(:find).and_return(@test_paged)
        expect(@test_paged).to receive(:destroy).and_raise(OrphanError)

        expect{ delete :destroy, id: @test_paged.pid }.to raise_error(OrphanError)
      end
    end
  end

  describe '#pages' do
    it 'should return pid and image ds uri given an index integer' do
      allow(ActiveFedora::SolrService).to receive(:instance).and_return(@mock_solr_service)

      index = 1
      get :pages, id: @test_paged.pid, index: index
      parsed = JSON.parse response.body
      expect(parsed['id']).to eq ordered_pages[index]
      expect(parsed['index']).to eq index.to_s
      expect(parsed['ds_url']).to match(/#{ERB::Util.url_encode(ordered_pages[index])}\/datastreams\/pageImage\/content$/)
    end
  end

  describe '#reorder' do

    context 'with no reorder values provided' do

      it 'flashes "No change"' do
        allow(Paged).to receive(:find).and_return(@test_paged)

        patch :reorder, id: @test_paged.pid, reorder_submission: nil
        expect(flash[:notice]).to match(/No change/i)
      end

      it 'redirects to :edit' do
        allow(Paged).to receive(:find).and_return(@test_paged)

        patch :reorder, id: @test_paged.pid, reorder_submission: nil
        expect(response).to redirect_to action: :edit
      end
    end

    context 'with valid reorder values' do

      let(:reorder_submission) { ordered_pages.reverse.map { |pid| { "id" => pid } }.to_json }

      it 'reorders pages' do
        #expect(Page).to receive(:find).at_least(:once) {|pid| @test_pages[pid.to_i-1]}
        allow(Paged).to receive(:find).and_return(@test_paged)

        expect(@test_paged).to receive("restructure_children").with(JSON.parse(reorder_submission))
        patch :reorder, id: @test_paged.pid, reorder_submission: reorder_submission
        # Check link order
#        ['2','3','4','5',nil].each_with_index {|p,i| expect(@test_pages[i].prev_sib).to eq(p)}
#        [nil,'1','2','3','4'].each_with_index {|p,i| expect(@test_pages[i].next_sib).to eq(p)}
      end

      it 'redirects to :edit' do
        allow(Paged).to receive(:find).and_return(@test_paged)

        patch :reorder, id: @test_paged.pid, reorder_submission: reorder_submission
        expect(response).to redirect_to action: :edit
      end
    end
  end

  describe '#bookreader' do
    render_views
    it 'assigns @paged' do
      allow(Paged).to receive(:find).and_return(@test_paged)
      get :bookreader, id: @test_paged.id
      expect(assigns(:paged)).to eq @test_paged
    end
    it 'renders :bookreader template' do
      allow(Paged).to receive(:find).and_return(@test_paged)
      get :bookreader, id: @test_paged.id
      expect(response).to render_template :bookreader
    end
  end

end
