# Copyright 2014 Indiana University.

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require_relative '../app/models/datastreams/paged_metadata_dublin_core'

describe PagedMetadataDublinCore do
  before(:each) do
    @paged_metadata_dublin_core = PagedMetadataDublinCore.new
  end

  describe '#xml_template' do
    it "returns an empty DC XML document" do
      expect(PagedMetadataDublinCore.xml_template.to_xml).to match(/oai_dc:dc/)
    end
  end

end

