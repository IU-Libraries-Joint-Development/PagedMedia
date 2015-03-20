class PagesController < ApplicationController
  before_action :set_page, only: [:show, :edit, :update, :destroy]
  before_action :set_paged, only: [:show]

  # GET /pages
  # GET /pages.json
  def index
    @pages = Page.all
    session[:came_from] = :page
    add_breadcrumb "Browse Pages"
  end

  # GET /pages/1
  # GET /pages/1.json
  def show
    session[:came_from] = :page
    my_parent = @page.parent_paged
    if my_parent
      paged = Paged.find(my_parent)
      add_breadcrumb paged.title, paged
      add_breadcrumb @page.logical_number, @page
    end
    
  end

  # GET /pages/new
  def new
    @page = Page.new
    session[:came_from] = :page
    add_breadcrumb "Create Page"
  end

  # GET /pages/1/edit
  def edit
    my_parent = @page.parent_paged
    if my_parent
      paged = Paged.find(my_parent)
      add_breadcrumb paged.title, paged
    end
    add_breadcrumb @page.logical_number, @page
    add_breadcrumb "Edit"
  end

  # POST /pages
  # POST /pages.json
  def create
    @page = Page.new(page_params)

    respond_to do |format|
      @page.image_file = params[:image_file] if params.has_key?(:image_file)
      @page.ocr_file = params[:ocr_file] if params.has_key?(:ocr_file)
      @page.xml_file = params[:xml_file] if params.has_key?(:xml_file)
      @page.parent = params[:parent] if params.has_key?(:parent)
      if @page.save
        my_parent = @page.parent_paged
        if my_parent
          paged = Paged.find(my_parent)
          paged.update_index
          format.html { redirect_to paged_path(my_parent), notice: 'Page was successfully created.'}
        else
          format.html { redirect_to @page, notice: 'Page was successfully created.' }
          format.json { render action: 'show', status: :created, location: @page }
        end
      else
        format.html { render action: 'new' }
        format.json { render json: @page.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /pages/1
  # PATCH/PUT /pages/1.json
  def update
    respond_to do |format|
      if @page.update(page_params)
        format.html do
          if (:paged == session.delete(:came_from))
            if @page.parent_paged
              return_url = paged_url(@page.parent_paged)
            else
              return_url = pageds_path
            end
            redirect_to return_url, notice: 'Page was successfully updated.'
          else
            redirect_to @page, notice: 'Page was successfully updated.'
          end
        end
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @page.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pages/1
  # DELETE /pages/1.json
  def destroy
    @page.destroy
    respond_to do |format|
      format.html { redirect_to pages_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_page
      @page = Page.find(params[:id])
    end

    def set_paged
      my_parent = @page.parent_paged
      @paged = Paged.find(my_parent) if my_parent
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def page_params
      params.require(:page).permit(:logical_number, :image_file, :ocr_file, :xml_file, :prev_sib, :next_sib, :parent, :children)
    end
end
