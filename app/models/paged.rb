# A binding of Page objects.
#--
# Copyright 2014 Indiana University.

class Paged < Node

  has_file_datastream 'pagedXML'

  has_metadata 'descMetadata', type: PagedMetadataOaiDc, label: 'PMP PagedObject descriptive metadata'

  has_attributes :title, datastream: 'descMetadata', multiple: false  # TODO update DC.title as well?
  has_attributes :creator, datastream: 'descMetadata', multiple: false
  has_attributes :publisher, datastream: 'descMetadata', multiple: false
  has_attributes :publisher_place, datastream: 'descMetadata', multiple: false
  has_attributes :issued, datastream: 'descMetadata', multiple: false
  has_attributes :type, datastream: 'descMetadata', multiple: false
  has_attributes :paged_struct, datastream: 'descMetadata', multiple: true


  # Setter for the XML datastream
  def xml_file=(file)
    ds = @datastreams['pagedXML']
    ds.content = file
    ds.mimeType = 'application/xml'
    ds.dsLabel = file.original_filename
  end

  # Getter for the XML datastream
  def xml_file
    @datastreams['pagedXML']
  end

  def xml_datastream
    @datastreams['pagedXML']
  end

  def page_list
    pages = []
    fedora_url = ActiveFedora.fedora_config.credentials[:url] + '/'
    self.order_children[0].each_with_index do |page, index|
      my_page = Page.find(page)
      pages.push({:id => my_page.pid, :index => index.to_s, :logical_number => my_page.logical_number, :ds_url => fedora_url + my_page.image_datastream.url})
    end
    pages
  end

  def to_solr(solr_doc={}, opts={})
    pages = self.page_list
    super(solr_doc, opts)
    solr_doc[Solrizer.solr_name('pages', 'ss')] = pages.to_json # single value field as json
    solr_doc[Solrizer.solr_name('pages', 'ssm')] = pages # multivalue field as ruby hash
    solr_doc[Solrizer.solr_name('item_id', 'si')] = self.pid
    return solr_doc
  end

end
