class Collection < ActiveFedora::Base
  VALID_PARENT_CLASSES = [Collection]
  VALID_CHILD_CLASSES = [Collection, Paged]
  include Node

  has_metadata 'descMetadata', type: CollectionMetadata

  has_attributes :name, datastream: 'descMetadata', multiple: false

  validates :name, presence: true

  # Additional values to include in hash used by descendent/ancestry list methods
  def additional_hash_values
    {name: name}
  end

end
