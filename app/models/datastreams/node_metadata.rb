# To change this license header, choose License Headers in Project Properties.
# To change this template file, choose Tools | Templates
# and open the template in the editor.

class NodeMetadata < ActiveFedora::OmDatastream

  set_terminology do |t|
    t.root(path: 'fields')
    t.prev_sib index_as: :stored_searchable
    t.next_sib index_as: :stored_searchable
  end

  def self.xml_template
    Nokogiri::XML.parse('<fields/>')
  end

end
