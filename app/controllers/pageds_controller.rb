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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_paged
      @paged = Paged.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def paged_params
      params.require(:paged).permit(:title, :creator, :type)
    end
end
