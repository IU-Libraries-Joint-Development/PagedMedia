# A single page, representing an image, possibly with one or more alternate views.
#--
# Copyright 2014 Indiana University

class Page < ActiveFedora::Base

  include Hydra::AccessControls::Permissions

  has_metadata 'descMetadata', type: PageMetadata
  
  belongs_to :paged, :property=> :is_part_of
  
  has_file_datastream 'pageImage'
  has_file_datastream 'pageOCR'

  has_attributes :logical_number, datastream: 'descMetadata',  multiple: false
  has_attributes :physical_number, datastream: 'descMetadata',  multiple: false
  has_attributes :text,  datastream: 'descMetadata', multiple: false

  # Setter for the image
  def image_file=(file)
    ds = @datastreams['pageImage']
    ds.content = file
    ds.mimeType = file.content_type
    ds.dsLabel = file.original_filename
  end

  # Getter for the image
  def image_file
    @datastreams['pageImage'].content
  end

  def image_datastream
    @datastreams['pageImage']
  end


  # Setter for the pageOCR file datastream
  def ocr_file=(file)
    ds = @datastreams['pageOCR']
    ds.content = file
    ds.mimeType = file.content_type
    ds.dsLabel = file.original_filename
  end

  # Getter for the pageOCR file datastream
  def ocr_file
    datastreams['pageOCR'].content
   end

  def ocr_datastream
    @datastreams['pageOCR']
  end


end
