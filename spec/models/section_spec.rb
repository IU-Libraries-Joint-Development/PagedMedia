# Copyright 2015 Indiana University

describe Section do

  let(:section) { FactoryGirl.create :section }
  let(:valid_section) { FactoryGirl.build :section }
  let(:invalid_section) { FactoryGirl.build :section, :invalid }
  let(:unchecked_section) { FactoryGirl.build :section, :unchecked }

  describe "FactoryGirl" do
    it "provides a valid valid_object" do
      expect(valid_section).to be_valid
    end
    it "provides an invalid invalid_object" do
      expect(invalid_section).to be_invalid
    end
    describe "with :unchecked trait" do
      it "has skip_linkage_validation" do
        expect(unchecked_section.skip_linkage_validation).to eq true
      end
    end
    describe "with :with_pages trait:" do
      specify "5 pages by default" do
        section_with_pages = FactoryGirl.create :section, :with_pages
	expect(Page.all.size).to eq 5
      end
      number_of_pages = 3
      specify "customizable number of pages: #{number_of_pages}" do
        section_with_pages = FactoryGirl.create :section, :with_pages, number_of_pages: number_of_pages
	expect(Page.all.size).to eq number_of_pages
      end
    end
  end

  describe "descMetadata" do
    it "has class SectionMetadata" do
      expect(valid_section.descMetadata.class).to eq SectionMetadata
    end
    it "includes the name attribute" do
      expect(valid_section.descMetadata.name.first).to eq valid_section.name
    end
  end

  describe "attributes" do
    specify "includes name" do
      expect(valid_section).to respond_to(:name)
    end
    specify "requires name" do
       valid_section.name = nil
       expect(valid_section).not_to be_valid
    end
  end

  # Node mix-in shared examples

  # Node traits, specific to this class
  describe "#valid_parent_classes" do
    subject(:class_array) { valid_section.valid_parent_classes }
    specify "equals [Paged, Section]" do
      expect(class_array.size).to eq 2
      expect(class_array).to include Paged
      expect(class_array).to include Section
    end
  end

end
