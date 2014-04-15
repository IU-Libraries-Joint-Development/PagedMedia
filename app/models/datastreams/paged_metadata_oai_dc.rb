# Represent an OAI_DC (Dublin Core XML) datastream.
#--
# Copyright 2014 Indiana University.

class PagedMetadataOaiDc < ActiveFedora::OmDatastream

  set_terminology do |t|
    t.root(path: 'oai_dc:dc',
      'xmlns:oai_dc' => 'http://www.openarchives.org/OAI/2.0/oai_dc/',
      'xmlns:dc' => 'http://purl.org/dc/elements/1.1/')
    t.title(namespace_prefix: 'dc')
    t.creator(namespace_prefix: 'dc')
  end

  def self.xml_template
    Nokogiri::XML.parse('<oai_dc:dc' \
      ' xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"' \
      ' xmlns:dc="http://purl.org/dc/elements/1.1/"/>')
  end
end
