class Collection < ActiveFedora::Base
  VALID_PARENT_CLASSES = [Collection]
  include Node

  has_metadata 'descMetadata', type: CollectionMetadata

  has_attributes :name, datastream: 'descMetadata', multiple: false

  validates :name, presence: true

end
