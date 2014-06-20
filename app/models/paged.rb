# A binding of Page objects.
#--
# Copyright 2014 Indiana University.

class Paged < ActiveFedora::Base

  include Hydra::AccessControls::Permissions

  has_metadata 'descMetadata', type: PagedMetadataOaiDc, label: 'PMP PagedObject descriptive metadata'

  has_many :pages, :property=> :is_part_of

  has_attributes :title, datastream: 'descMetadata', multiple: false  # TODO update DC.title as well?
  has_attributes :creator, datastream: 'descMetadata', multiple: false
  has_attributes :type, datastream: 'descMetadata', multiple: false

  def Paged.order_pages(paged)    
    # Get First Page
    @error = false
    @first_page = false
    @page_ids = Array.new
    paged.pages.each do |page|
      @page_ids << page.pid
      next if page.prev_page != ''
      # Check for Multiple first pages
      if !@first_page
        @first_page = page
      else
        @error = "Multiple First Pages"
      end
    end
    @ordered_pages = Array.new
    @next_page = @first_page
    @pages = Array.new
    while @next_page do
      @ordered_pages << @next_page
      @np_id = @next_page.next_page
      if @pages.include?(@np_id)
        # Check for infinite loop
        @error = "Infinite loop of pages"
        @next_page = false
      elsif @np_id != ''
        if @page_ids.include?(@np_id)
          @pages << @np_id
          @next_page = Page.find(@np_id)
        else
          # Page not part of Paged object
          @errors = "Page not Found in Listing"
          @next_page = false
        end
      else 
        @next_page = false
      end
    end
    # Check if all pages are included
    if @ordered_pages.count < paged.pages.count 
      @error = "Pages Missing From List"
    end
    return [@ordered_pages, @error]
  end

end
