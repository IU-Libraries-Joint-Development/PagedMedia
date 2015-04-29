# A single page, representing an image, possibly with one or more alternate views.
#--
# Copyright 2014 Indiana University

class Page < ActiveFedora::Base
  VALID_PARENT_CLASSES = [Paged, Section]
  VALID_CHILD_CLASSES = []
  include Node

  has_metadata "descMetadata", type: PageDescMetadata, label: 'PMP PageObject descriptive metadata'
  has_metadata 'pageMetadata', type: PageMetadata

  has_file_datastream 'pageImage'
  has_file_datastream 'pageOCR'
  has_file_datastream 'pageXML'
  
  # Single-value fields
  has_attributes :title, :contributor, :creator, :coverage, :issued, :date, :description,
                 :identifier, :language, :publisher, :publisher_place,
                 :rights, :source, :subject, :type,
                 :text, :logical_number,
                 datastream: :descMetadata, multiple: false
  has_attributes :logical_number, datastream: 'pageMetadata',  multiple: false
  has_attributes :text,  datastream: 'pageMetadata', multiple: false
  
  #Multiple-value fields
  has_attributes :page_struct, datastream: 'pageMetadata', multiple: true

  before_save :update_page_struct

  # Setter for the image
  def image_file=(file)
    ds = @datastreams['pageImage']
    ds.content = file
    # mimeType automatically set
    # FIXME: workaround for deprecated original_filename
    ds.dsLabel = file.inspect.sub /.*\/(.*)\>/, '\1'
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
    # mimeType automatically set
    ds.dsLabel = file.inspect.sub /.*\/(.*)\>/, '\1'
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
    ds.dsLabel = file.inspect.sub /.*\/(.*)\>/, '\1'
  end

  # Getter for the XML datastream
  def xml_file
    @datastreams['pageXML']
  end

  def xml_datastream
    @datastreams['pageXML']
  end

  def self.fedora_url
    @fedora_url ||= ActiveFedora.fedora_config.credentials[:url] + '/'
  end

  # Additional values to include in hash used by descendent/ancestry list methods
  def additional_hash_values
    #FIXME: stash fedora_url and re-use
    #fedora_url = ActiveFedora.fedora_config.credentials[:url] + '/'
    {logical_number: logical_number, ds_url: self.class.fedora_url + image_datastream.url}
  end

  def to_solr(solr_doc={}, opts={})
    super(solr_doc, opts)
    if (!parent.nil?)
      solr_doc[Solrizer.solr_name('item_id', 'si')] = parent
    end
    return solr_doc
  end

  def update_page_struct(delimiter = '--')
    new_struct = []
    new_struct.unshift(logical_number) if logical_number
    self.list_ancestors(Section).reverse_each do |section|
      new_struct.unshift(section[:name])
    end
    new_struct.each_with_index do |value, index|
      new_struct[index] = new_struct[index - 1] + delimiter + value unless index == 0
    end
    self.page_struct = new_struct
  end
end
