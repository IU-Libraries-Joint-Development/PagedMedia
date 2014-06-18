# A single page, representing an image, possibly with one or more alternate views.
#--
# Copyright 2014 Indiana University

class Page < ActiveFedora::Base

  include Hydra::AccessControls::Permissions

  has_metadata 'descMetadata', type: PageMetadata

  belongs_to :paged, :property=> :is_part_of

  has_file_datastream 'pageImage'
  has_file_datastream 'pageOCR'
  has_file_datastream 'pageXML'

  has_attributes :logical_number, datastream: 'descMetadata',  multiple: false
  has_attributes :prev_page, datastream: 'descMetadata', multiple: false
  has_attributes :next_page, datastream: 'descMetadata', multiple: false
  has_attributes :text,  datastream: 'descMetadata', multiple: false

  validate :siblings_must_exist

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
    @datastreams['pageOCR'].content
  end

  def ocr_datastream
    @datastreams['pageOCR']
  end

  # Setter for the XML datastream
  def xml_file=(file)
    ds = @datastreams['pageXML']
    ds.content = file
    ds.mimeType = 'application/xml'
    ds.dsLabel = file.original_filename
  end

  # Getter for the XML datastream
  def xml_file
    @datastreams['pageXML']
  end

  def xml_datastream
    @datastreams['pageXML']
  end

  private
  def siblings_must_exist
    if (!paged.nil?) # FIXME should we allow unowned Page?

      found = false
      if (!prev_page.nil?)
        paged.pages.each do |a_page|
          found = true if a_page.pid == prev_page
        end
        errors.add(:prev_page, "Previous page #{prev_page} not in #{paged.pid}") if !found
      end

      found = false
      if (!next_page.nil?)
        paged.pages.each do |a_page|
          found = true if a_page.pid == next_page
        end
        errors.add(:next_page, "Next page #{next_page} not in #{paged.pid}") if !found
      end

    end
  end

  def before_save
  end
end
