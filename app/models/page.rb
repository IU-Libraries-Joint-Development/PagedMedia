# A single page, representing an image, possibly with one or more alternate views.
#--
# Copyright 2014 Indiana University

class Page < ActiveFedora::Base

  include Node

  has_metadata 'descMetadata', type: PageMetadata

  has_file_datastream 'pageImage'
  has_file_datastream 'pageOCR'
  has_file_datastream 'pageXML'

  has_attributes :logical_number, datastream: 'descMetadata',  multiple: false
  has_attributes :text,  datastream: 'descMetadata', multiple: false
  has_attributes :page_struct, datastream: 'descMetadata', multiple: true

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


  def to_solr(solr_doc={}, opts={})
    super(solr_doc, opts)
    if (!parent.nil?)
      solr_doc[Solrizer.solr_name('item_id', 'si')] = parent
    end
    return solr_doc
  end
end
