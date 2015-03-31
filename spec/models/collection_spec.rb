# Copyright 2015 Indiana University

describe Collection do

  let(:collection) { FactoryGirl.create :collection }
  let(:valid_collection) { FactoryGirl.build :collection }
  let(:invalid_collection) { FactoryGirl.build :collection, :invalid }

  describe "FactoryGirl" do
    it "provides a valid valid_object" do
      expect(valid_collection).to be_valid
    end
    it "provides an invalid invalid_object" do
      expect(invalid_collection).to be_invalid
    end
  end

  describe "descMetadata" do
    it "has class CollectionMetadata" do
      expect(valid_collection.descMetadata.class).to eq CollectionMetadata
    end
    it "includes the name attribute" do
      expect(valid_collection.descMetadata.name.first).to eq valid_collection.name
    end
  end

  describe "attributes" do
    specify "includes name" do
      expect(valid_collection).to respond_to(:name)
    end
    specify "requires name" do
       valid_collection.name = nil
       expect(valid_collection).not_to be_valid
    end
  end

  # Node mix-in shared examples

  # Node traits, specific to this class
  describe "#valid_parent_classes" do
    subject(:class_array) { valid_collection.valid_parent_classes }
    specify "equals [Collection]" do
      expect(class_array.size).to eq 1
      expect(class_array).to include Collection
    end
  end

end
