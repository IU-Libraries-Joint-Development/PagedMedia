class SectionsController < ApplicationController
  before_action :set_section, only: [:show, :edit, :update, :destroy]
  before_action :set_paged, only: [:index, :new, :create]

  def index
    if @paged
      @sections = Section.where(parent: @paged.pid)
    else
      @sections = Section.all
    end
  end

  def show
  end

  def new
    if @paged
      @section = Section.new(parent: @paged.pid)
    else
      @section = Section.new
    end
  end

  def edit
  end

  def create

    @paged = Paged.find(params[:section][:paged_id]) if params[:section][:paged_id]
    params[:section].delete :paged_id if params[:section][:paged_id]
    
    @section = Section.new(section_params)

    respond_to do |format|
      if @section.save
        if @paged
          format.html { redirect_to @paged, notice: 'Section was successfully created.'}
        else
          format.html { redirect_to @section, notice: 'Section was successfully created.' }
          format.json { render action: 'show', status: :created, location: @section }
        end
      else
        format.html { render action: 'new' }
        format.json { render json: @section.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @section.update(section_params)
        format.html { redirect_to @section, notice: 'Section was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @section.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @section.destroy
    respond_to do |format|
      format.html { redirect_to paged_sections_path(@section.parent) }
      format.json { head :no_content }
    end
  end

  private
    def set_section
      @section = Section.find(params[:id])
    end

    def set_paged
      @paged = Paged.find(params[:paged_id]) if params[:paged_id]
    end

    def section_params
      
      params.require(:section).permit(:name, :prev_sib, :next_sib, :parent, :children, :paged_id )
    end
end
