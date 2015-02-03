# Copyright 2014 Indiana University

describe PageMetadata do

  describe "#xml_template" do
    it "should produce an empty XML document" do
      expect(PageMetadata.xml_template.to_xml).to match(/\<fields\/\>/)
    end
  end

end
