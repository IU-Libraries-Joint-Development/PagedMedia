# Copyright 2014 Indiana University

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe PageMetadata do

  before { @paged_metadata = PagedMetadataOaiDc.new }

  subject { @paged_metadata }

  describe "#xml_template" do
    it "should produce an empty XML document" do
      expect(PagedMetadataOaiDc.xml_template.to_xml).to match(/oai_dc:dc/)
    end
  end

end
