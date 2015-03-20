# Copyright 2015 Indiana University

describe SectionsController do
  render_views
  let(:paged) { FactoryGirl.create :paged }
  let(:section) { FactoryGirl.create :section, parent: paged.pid }
  let(:other_section) { FactoryGirl.create :section }
  let(:valid_attributes) { FactoryGirl.attributes_for(:section) }
  let(:invalid_attributes) { FactoryGirl.attributes_for(:section, :invalid) }
  let(:updated_name) { "Updated Name" }
  let(:updated_attributes) { FactoryGirl.attributes_for(:section, name: updated_name) }


  describe "GET index" do
    before(:each) { section; other_section; get :index, paged_id: paged.pid }
    it "assigns pageds sections as @sections" do
      expect(assigns(:sections)).to eq([section])
    end
    it "renders the :index template" do
      expect(response).to render_template :index
    end
  end

  describe "GET show" do
    before(:each) { get :show, id: section.pid }
    it "assigns the requested section as @section" do
      expect(assigns(:section)).to eq(section)
    end
    it "renders the :show template" do
      expect(response).to render_template :show
    end
  end

  describe "GET new" do
    before(:each) { get :new, paged_id: paged.pid }
    it "assigns a new section as @section" do
      expect(assigns(:section)).to be_a_new(Section)
      expect(assigns(:section).parent).to eq paged.pid
    end
    it "renders the :new template" do
      expect(response).to render_template :new
    end
  end

  describe "GET edit" do
    before(:each) { get :edit, id: section.pid }
    it "assigns the requested section as @section" do
      expect(assigns(:section)).to eq(section)
    end
    it "renders the :edit template" do
      expect(response).to render_template :edit
    end
  end

  describe "POST create" do
    describe "with valid params" do
      let(:post_create) { post :create, paged_id: paged.pid, section: valid_attributes }
      it "creates a new Section" do
        expect { post_create }.to change(Section, :count).by(1)
      end
      it "assigns a newly created section as @section" do
        post_create
        expect(assigns(:section)).to be_a(Section)
        expect(assigns(:section)).to be_persisted
      end
      it "redirects to the created section" do
        post_create
        expect(response).to redirect_to(Section.last)
      end
    end

    describe "with invalid params" do
      let(:post_create) { post :create, paged_id: paged.pid, section: invalid_attributes }
      it "assigns a newly created but unsaved section as @section" do
        post_create
        expect(assigns(:section)).to be_a_new(Section)
        expect(assigns(:section)).not_to be_persisted
      end

      it "re-renders the 'new' template" do
        post_create
        expect(response).to render_template :new
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      before(:each) { put :update, id: section.pid, section: updated_attributes }
      it "updates the requested section" do
        expect(section.name).not_to eq updated_name
        section.reload
        expect(section.name).to eq updated_name
      end
      it "assigns the requested section as @section" do
        expect(assigns(:section)).to eq section 
      end
      it "redirects to the section" do
        expect(response).to redirect_to section
      end
    end

    describe "with invalid params" do
      before(:each) { put :update, id: section.pid, section: invalid_attributes }
      it "assigns the section as @section" do
        expect(assigns(:section)).to eq section 
      end
      it "re-renders the 'edit' template" do
        expect(response).to render_template :edit
      end
    end
  end

  describe "DELETE destroy" do
    let(:delete_destroy) { delete :destroy, id: section.pid }
    it "destroys the requested section" do
      section
      expect { delete_destroy }.to change(Section, :count).by(-1)
    end
    it "redirects to the sections list" do
      delete_destroy
      expect(response).to redirect_to paged_sections_path(paged)
    end
  end

end
