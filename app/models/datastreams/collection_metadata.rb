# Copyright 2015 Indiana University

class CollectionMetadata < ActiveFedora::OmDatastream

  set_terminology do |t|
    t.root(path: 'fields')
    t.name index_as: :stored_searchable
  end

  def self.xml_template
    Nokogiri::XML.parse('<fields/>')
  end

end
