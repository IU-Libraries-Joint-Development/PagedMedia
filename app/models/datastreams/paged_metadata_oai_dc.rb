# Represent an OAI_DC (Dublin Core XML) datastream.
#--
# Copyright 2014 Indiana University.

class PagedMetadataOaiDc < ActiveFedora::OmDatastream

  set_terminology do |t|
    t.root(path: 'oai_dc:dc',
      'xmlns:oai_dc' => 'http://www.openarchives.org/OAI/2.0/oai_dc/',
      'xmlns:dc' => 'http://purl.org/dc/elements/1.1/')
    t.type(namespace_prefix: 'dc', index_as: :stored_searchable)
    t.title(namespace_prefix: 'dc', index_as: :stored_searchable)
    t.creator(namespace_prefix: 'dc', index_as: :stored_searchable)
    t.publisher(namespace_prefix: 'dc', index_as: :stored_searchable)
    t.publisher_place(namespace_prefix: 'dc', index_as: :stored_searchable)
    t.issued(namespace_prefix: 'dc', index_as: :stored_searchable, type: :date)
    t.treestruct(namespace_prefix: 'dc', index_as: :stored_searchable)
  end

  def self.xml_template
    Nokogiri::XML.parse('<oai_dc:dc' \
      ' xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"' \
      ' xmlns:dc="http://purl.org/dc/elements/1.1/"/>')
  end
end
