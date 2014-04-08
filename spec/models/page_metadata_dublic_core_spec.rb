# Copyright 2014 Indiana University

require 'spec_helper'

describe PageMetadata do

  before { @page_metadata = PageMetadata.new }

  subject { @page_metadata }

  describe "#xml_template" do
    it "should produce an empty XML document" do
      expect(PageMetadata.xml_template.to_xml).to match(/\<fields\/\>/)
    end
  end

end
