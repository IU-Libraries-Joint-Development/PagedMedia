# Copyright 2014 Indiana University

class PageMetadata < ActiveFedora::OmDatastream

  set_terminology do |t|
    t.root(path: 'fields')
    t.logical_number index_as: :stored_searchable
    t.physical_number index_as: :stored_searchable, type: :integer
    t.text index_as: :stored_searchable

  end

  def self.xml_template
    Nokogiri::XML.parse('<fields/>')
  end

end
