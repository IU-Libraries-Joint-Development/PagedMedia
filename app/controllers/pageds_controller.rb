class PagedsController < ApplicationController
  before_action :set_paged, only: [:show, :edit, :update, :destroy]

  # GET /pageds
  # GET /pageds.json
  def index
    @pageds = Paged.all
  end

  # GET /pageds/1
  # GET /pageds/1.json
  def show
    @ordered, @error = @paged.order_pages()
    if @error
      flash.now[:error] = "ERROR Ordering Items : #{@error}"
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

  def reorder
    unless params[:reorder_submission].nil? || params[:reorder_submission].blank?
      page_id_list = params[:reorder_submission].to_s.split(',') unless params[:reorder_submission].nil?
      page_id_list ||= []
      puts "page_id_list: #{page_id_list.inspect}"
      #build pages array
      pages_array = []
      page_id_list.each do |page_id|
        puts "page_id: #{page_id}"
        pages_array << Page.find(page_id)
        puts "pages_array(#{pages_array.size}): #{pages_array.inspect}"
      end
      puts "AFTER BUILD: #{pages_array.inspect}"
      #reset numbers
      pages_array.each_with_index do |page, index|
        puts "position: #{index + 1}, #{page.id}"
        page.logical_number = (index + 1).to_s
      end
      puts "AFTER NUMBERS: #{pages_array.inspect}"
      #reset previous pages
      previous_page = nil
      pages_array.each do |page|
        page.prev_page = previous_page
        previous_page = page.id
      end
      puts "AFTER PREVIOUS: #{pages_array.inspect}"
      #reset next pages
      next_page = nil
      pages_array.reverse_each do |page|
        page.next_page = next_page
        next_page = page.id
        puts "next_page: #{next_page.inspect}"
      end
      puts "AFTER NEXT: #{pages_array.inspect}"
      flash[:notice] = ""
      pages_array.each do |page|
        if page.save(unchecked: 1)
          flash[:notice] += "#{page.logical_number}: #{page.id} SUCCESS | "
        else
          flash[:notice] += "#{page.logical_number}: #{page.id} #{page.errors.messages.to_s} | "
        end
      end
    else
      flash[:notice] = "No changes to the page order were submitted."
    end
    redirect_to action: :show
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_paged
      @paged = Paged.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def paged_params
      params.require(:paged).permit(:title, :creator, :type)
    end

    def reorder_params
      params.permit(:reorder_submission)
    end
end
