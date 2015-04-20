# Copyright 2015 Indiana University

describe CollectionsController do
  render_views
  let(:collection) { FactoryGirl.create :collection }
  let(:valid_attributes) { FactoryGirl.attributes_for(:collection) }
  let(:invalid_attributes) { FactoryGirl.attributes_for(:collection, :invalid) }
  let(:updated_name) { "Updated Name" }
  let(:updated_attributes) { FactoryGirl.attributes_for(:collection, name: updated_name) }


  describe "GET index" do
    before(:each) { collection; get :index }
    it "assigns all collections as @collections" do
      expect(assigns(:collections)).to eq([collection])
    end
    it "renders the :index template" do
      expect(response).to render_template :index
    end
  end

  describe "GET show" do
    before(:each) { get :show, id: collection.pid }
    it "assigns the requested collection as @collection" do
      expect(assigns(:collection)).to eq(collection)
    end
    it "renders the :show template" do
      expect(response).to render_template :show
    end
  end

  describe "GET new" do
    before(:each) { get :new }
    it "assigns a new collection as @collection" do
      expect(assigns(:collection)).to be_a_new(Collection)
    end
    it "renders the :new template" do
      expect(response).to render_template :new
    end
  end

  describe "GET edit" do
    before(:each) { get :edit, id: collection.pid }
    it "assigns the requested collection as @collection" do
      expect(assigns(:collection)).to eq(collection)
    end
    it "renders the :edit template" do
      expect(response).to render_template :edit
    end
  end

  describe "POST create" do
    describe "with valid params" do
      let(:post_create) { post :create, collection: valid_attributes }
      it "creates a new Collection" do
        expect { post_create }.to change(Collection, :count).by(1)
      end
      it "assigns a newly created collection as @collection" do
        post_create
        expect(assigns(:collection)).to be_a(Collection)
        expect(assigns(:collection)).to be_persisted
      end
      it "redirects to the created collection" do
        post_create
        expect(response).to redirect_to(Collection.last)
      end
    end

    describe "with invalid params" do
      let(:post_create) { post :create, collection: invalid_attributes }
      it "assigns a newly created but unsaved collection as @collection" do
        post_create
        expect(assigns(:collection)).to be_a_new(Collection)
        expect(assigns(:collection)).not_to be_persisted
      end

      it "re-renders the 'new' template" do
        post_create
        expect(response).to render_template :new
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested collection" do
        expect(collection.name).not_to eq updated_name
        put :update, id: collection.pid, collection: updated_attributes
        collection.reload
        expect(collection.name).to eq updated_name
      end
      it "assigns the requested collection as @collection" do
        put :update, id: collection.pid, collection: updated_attributes
        expect(assigns(:collection)).to eq collection 
      end
      it "redirects to the collection" do
        put :update, id: collection.pid, collection: updated_attributes
        expect(response).to redirect_to collection
      end
    end

    describe "with invalid params" do
      before(:each) { put :update, id: collection.pid, collection: invalid_attributes }
      it "assigns the collection as @collection" do
        expect(assigns(:collection)).to eq collection 
      end
      it "re-renders the 'edit' template" do
        expect(response).to render_template :edit
      end
    end
  end

  describe "DELETE destroy" do
    let(:delete_destroy) { delete :destroy, id: collection.pid }
    it "destroys the requested collection" do
      collection
      expect { delete_destroy }.to change(Collection, :count).by(-1)
    end
    it "redirects to the collections list" do
      delete_destroy
      expect(response).to redirect_to collections_path
    end
  end

end
