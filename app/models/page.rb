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

  validate :validate_siblings_exist
  validate :validate_has_required_siblings

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

  # If a page declares siblings, ensure that the Paged knows them.
  private
  def validate_siblings_exist
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

  # If the Paged is empty, sibling pointers should be nil.
  # Otherwise each pointer in this Page should point to corresponding sib's
  # other sib.
  def validate_has_required_siblings
    return if paged.nil? # FIXME should we allow unowned Page?

    if (paged.pages.size == 0)
      errors.add(:prev_page, 'prev_page must be nil') if prev_page
      errors.add(:next_page, 'next_page must be nil') if next_page
      return
    end

    errors[:base] << 'must have one or both siblings if other pages exist' if (prev_page.nil? && next_page.nil?)

    if (prev_page)
      prev_sib = Page.find(prev_page)
      errors.add(:next_page, 'Invalid next_page') if prev_sib.next_page != next_page
    end

    if (next_page)
      next_sib = Page.find(next_page)
      errors.add(:prev_page, 'Invalid prev_page') if next_sib.prev_page != prev_page
    end
  end

  # Link this page into the list
  def before_save
#    if (prev_page)
#      prev_sib = Page.find(prev_page)
#      prev_sib.next_page = pid
#      prev_sib.save!
#    end
#
#    if (next_page)
#      next_sib = Page.find(next_page)
#      next_sib.next_page = pid
#      next_sib.save!
#    end
  end

  # Unlink this page from the list
  def before_destroy
#    if (prev_page)
#      prev_sib = Page.find(prev_page)
#    end
#    if (next_page)
#      next_sib = Page.find(next_page)
#    end
#    if (prev_sib)
#      prev_sib.next_page = next_sib ? next_sib.pid : nil
#      prev_sib.save!
#    end
#    if (next_sib)
#      next_sib.prev_page = prev_sib ? prev_sib.pid : nil
#      next_sib.save!
#    end
  end

end
