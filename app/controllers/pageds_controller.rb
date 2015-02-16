class PagedsController < ApplicationController
  before_action :set_paged, only: [:show, :edit, :update, :destroy, :bookreader, :validate]

  # GET /pageds
  # GET /pageds.json
  def index
    @pageds = Paged.all
  end

  # GET /pageds/1
  # GET /pageds/1.json
  def show
    @ordered = JSON.parse(find_pages())
  end

  def validate
    @ordered = JSON.parse(find_pages())
    validated, @error = @paged.order_pages()
    if @error
      flash.now[:error] = "ERROR Ordering Items : #{@error}"
    end
    respond_to do |format|
      format.html { render action: 'show' }
      format.json { render action: 'show' }
    end
  end

  # GET /pageds/new
  def new
    @paged = Paged.new
  end

  # GET /pageds/1/edit
  def edit
  end

  # POST /pageds
  # POST /pageds.json
  def create
    @paged = Paged.new(paged_params)

    respond_to do |format|
      if @paged.save
        format.html { redirect_to @paged, notice: 'Paged was successfully created.' }
        format.json { render action: 'show', status: :created, location: @paged }
      else
        format.html { render action: 'new' }
        format.json { render json: @paged.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /pageds/1
  # PATCH/PUT /pageds/1.json
  def update
    respond_to do |format|
      if @paged.update(paged_params)
        format.html { redirect_to @paged, notice: 'Paged was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @paged.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pageds/1
  # DELETE /pageds/1.json
  def destroy
    @paged.destroy
    respond_to do |format|
      format.html { redirect_to pageds_url }
      format.json { head :no_content }
    end
  end

  # GET /pageds/1/pages
  # GET /pageds/1/pages.json
  def pages
    page_rsp = {}
    search = find_pages
    parsed = JSON.parse(search)
    if params[:index].nil?
      page_rsp = parsed
    else
      unless params[:index].to_i > parsed.count
        page_id = parsed[params[:index].to_i]['id']
        ds_url = parsed[params[:index].to_i]['ds_url']
        logical_number = parsed[params[:index].to_i]['logical_number']
        ds_url ||= ''
        page_rsp = {:id => page_id, :index => params[:index], :logical_number => logical_number, :ds_url => ds_url}
      else
        page_rsp = {:id => params[:id], :index => params[:index], :error => 'Index out of bounds'}
      end
    end
    respond_to do |format|
      format.html { render json: page_rsp, head: :no_content }
      format.json { render json: page_rsp, head: :no_content}
    end
  end

  def bookreader
    render layout: false
  end

  def reorder
    unless params[:reorder_submission].nil? || params[:reorder_submission].blank?
      page_ids = params[:reorder_submission].to_s.split(',')
      page_ids ||= []
      pages = []
      page_ids.each do |page_id|
        pages << Page.find(page_id)
      end

      previous_page = nil
      pages.each do |page|
        page.skip_sibling_validation = true
        page.prev_page = previous_page
        previous_page = page.id
      end
      next_page = nil
      pages.reverse_each do |page|
        page.next_page = next_page
        next_page = page.id
      end

      page_errors = ""
      pages.each do |page|
        if !page.save(unchecked: 1)
          page_errors += "#{page.logical_number}. #{page.id} save error: #{page.errors.messages.to_s} | "
        end
      end
      if page_errors.blank?
        @paged = Paged.find(params[:id])
        @paged.update_index 
      end  
      flash[:notice] = page_errors unless page_errors.blank?
    else
      flash[:notice] = "No changes to the page order were submitted."
    end
    redirect_to action: :show
  end

  private

  def find_pages
    pages = {}
    search = ActiveFedora::SolrService.instance.conn.select :params => { :q => params[:id], :fl => "pages_ss" }
    unless search['response']['numFound'].to_i == 0
      pages = search['response']['docs'][0]['pages_ss']
    else
      pages = {:id => params[:id], :error => 'No pages'}
    end
    return pages
  end


    # Use callbacks to share common setup or constraints between actions.
    def set_paged
      @paged = Paged.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def paged_params
      params.require(:paged).permit(:type, :title, :creator, :publisher, :publisher_place, :issued, :xml_file)
    end

    def reorder_params
      params.permit(:reorder_submission)
    end
end
