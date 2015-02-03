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
  has_attributes :page_struct, datastream: 'descMetadata', multiple: true

  attr_accessor :skip_sibling_validation
  validate :validate_has_required_siblings, unless: :skip_sibling_validation


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



  # A link is "unset" if it is nil or an empty String
  def unset(attribute)
    attribute.nil? || attribute.empty?
  end

  # If the Paged is empty, sibling pointers should be nil, otherwise at least
  # one must be non-nil.
  def validate_has_required_siblings
    puts "HI ADAM"
    return if paged.nil? # FIXME should we allow unowned Page?

    # No pages yet, so this page can't have siblings
    if (paged.pages.size == 0)
      errors.add(:prev_page, 'prev_page must be empty') if !unset(prev_page)
      errors.add(:next_page, 'next_page must be empty') if !unset(next_page)
      return
    end

    # At least one page already exists.  Must have at least one sibling
    # unless the one page is this one (we are updating, not creating).
    if (unset(prev_page) && unset(next_page) &&
        ((paged.pages.size > 1) || (paged.pages.first.pid != pid)))
      errors[:base] << 'must have one or both siblings if other pages exist'
    end
  end


  # Link this page into the list.
  # These saves should be in a transaction, but does Fedora do transactions?
  #
  # 'foo.save(unchecked: 1)' bypasses integrity checks.  Don't!  It's for this
  # method's internal use.
  def save(opts={})

    if (opts.has_key?(:unchecked))
      return super()
    end

    if (!unset(prev_page))
      found = false
      if (!paged.nil?)
        paged.pages.each do |a_page|
          found = true if a_page.pid == prev_page
        end
        if !found
          errors.add(:prev_page, "#{prev_page} not in #{paged.pid}")
          return false
        end
      else
        errors.add(:prev_page, 'Unowned page cannot have siblings')
        return false
      end

      prev_sib = Page.find(prev_page)
      if (prev_sib.next_page != next_page) && (prev_sib.next_page != pid)
        errors.add(:next_page, 'invalid')
        return false
      end
    end

    if (!unset(next_page))
      found = false
      if (!paged.nil?)
        paged.pages.each do |a_page|
          found = true if a_page.pid == next_page
        end
        if !found
          errors.add(:next_page, "#{next_page} not in #{paged.pid}")
          return false
        end
      else
        errors.add(:next_page, 'Unowned page cannot have siblings')
        return false
      end

      next_sib = Page.find(next_page)
      if (next_sib.prev_page != prev_page) && (next_sib.prev_page != pid)
        errors.add(:prev_page, 'invalid')
        return false
      end
    end

    begin
      return false if ! super()
    rescue RestClient::BadRequest => e
      errors[:base] << e.message
      errors[:base] << 'Check for a damaged or invalid file'
      return false
    end

    if (!unset(prev_page))
      prev_sib = Page.find(prev_page)
      prev_sib.next_page = pid
      prev_sib.save(unchecked: 1)
    end

    if (!unset(next_page))
      next_sib = Page.find(next_page)
      next_sib.prev_page = pid
      next_sib.save(unchecked: 1)
    end

    true
  end

  # Unlink this page from the list
  def delete
    begin
      prev_sib = Page.find(prev_page) if (!unset(prev_page))
    rescue ActiveFedora::ObjectNotFoundError => e
      logger.error("deleting #{pid}, missing prev_page: #{e}")
    end

    begin
      next_sib = Page.find(next_page) if (!unset(next_page))
    rescue ActiveFedora::ObjectNotFoundError => e
      logger.error("deleting #{pid}, missing next_page: #{e}")
    end

    if (prev_sib)
      prev_sib.next_page = next_sib ? next_sib.pid : nil
      prev_sib.save(unchecked: 1)
    end

    if (next_sib)
      next_sib.prev_page = prev_sib ? prev_sib.pid : nil
      next_sib.save(unchecked: 1)
    end

    super
  end

  def to_solr(solr_doc={}, opts={})
    super(solr_doc, opts)
    if (!paged.nil?)
      solr_doc[Solrizer.solr_name('item_id', 'si')] = paged.pid
    end
    return solr_doc
  end

end
