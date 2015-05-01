# A binding of Page objects.
#--
# Copyright 2014 Indiana University.

class Paged < ActiveFedora::Base

  validates :issued,
  format: { with: /\A(19|20)\d\d([- \/.])(0[1-9]|1[012])\2(0[1-9]|[12][0-9]|3[01])\z/,
    message: "Date format must be yyyy-mm-dd",
    allow_blank: true }
  
  VALID_PARENT_CLASSES = [Collection]
  VALID_CHILD_CLASSES = [Section, Page]
  include Node

  has_file_datastream 'pagedXML'

  has_metadata "descMetadata", type: PagedDescMetadata, label: 'PMP PagedObject descriptive metadata'

  # Single-value fields
  has_attributes :title, :contributor, :creator, :coverage, :issued, :date, :description,
                 :identifier, :language, :publisher, :publisher_place,
                 :rights, :source, :subject, :type, datastream: :descMetadata, multiple: false
  # Multi-value fields
  has_attributes :paged_struct, datastream: :descMetadata, multiple: true

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

  # Additional values to include in hash used by descendent/ancestry list methods
  def additional_hash_values
    {title: title}
  end

  def to_solr(solr_doc={}, opts={})
    pages = self.list_descendents(Page)
    super(solr_doc, opts)
    solr_doc[Solrizer.solr_name('pages', 'ss')] = pages.to_json # single value field as json
    solr_doc[Solrizer.solr_name('pages', 'ssm')] = pages # multivalue field as ruby hash
    solr_doc[Solrizer.solr_name('item_id', 'si')] = self.pid
    return solr_doc
  end

  def update_paged_struct(delimiter = '--')
    new_struct = []
    self.list_ancestors(Collection).reverse_each do |collection|
      new_struct.unshift(collection[:name])
    end
    new_struct.each_with_index do |value, index|
      new_struct[index] = new_struct[index - 1] + delimiter + value unless index == 0
    end
    self.paged_struct = new_struct
  end

end
