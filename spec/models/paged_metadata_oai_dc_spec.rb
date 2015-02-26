# Copyright 2014 Indiana University

describe PageMetadata do

  before { @paged_metadata = PagedMetadataOaiDc.new }

  subject { @paged_metadata }

  describe "#xml_template" do
    it "should produce an empty XML document" do
      expect(PagedMetadataOaiDc.xml_template.to_xml).to match(/oai_dc:dc/)
    end
  end

end
