# A binding of Page objects.
#--
# Copyright 2014 Indiana University.

class Paged < ActiveFedora::Base
  VALID_PARENT_CLASSES = [Collection]
  include Node

  has_file_datastream 'pagedXML'

  has_metadata 'descMetadata', type: PagedMetadataOaiDc, label: 'PMP PagedObject descriptive metadata'

  has_attributes :title, datastream: 'descMetadata', multiple: false  # TODO update DC.title as well?
  has_attributes :creator, datastream: 'descMetadata', multiple: false
  has_attributes :publisher, datastream: 'descMetadata', multiple: false
  has_attributes :publisher_place, datastream: 'descMetadata', multiple: false
  has_attributes :issued, datastream: 'descMetadata', multiple: false
  has_attributes :type, datastream: 'descMetadata', multiple: false
  has_attributes :paged_struct, datastream: 'descMetadata', multiple: true

  before_save :update_paged_struct

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

  def to_solr(solr_doc={}, opts={})
    pages = self.page_list
    super(solr_doc, opts)
    solr_doc[Solrizer.solr_name('pages', 'ss')] = pages.to_json # single value field as json
    solr_doc[Solrizer.solr_name('pages', 'ssm')] = pages # multivalue field as ruby hash
    solr_doc[Solrizer.solr_name('item_id', 'si')] = self.pid
    return solr_doc
  end

  def update_paged_struct(delimiter = '--')
    new_struct = []
    self.supercollections.reverse_each do |collection|
      new_struct.unshift(collection[:name])
    end
    new_struct.each_with_index do |value, index|
      new_struct[index] = new_struct[index - 1] + delimiter + value unless index == 0
    end
    self.paged_struct = new_struct
  end

end
