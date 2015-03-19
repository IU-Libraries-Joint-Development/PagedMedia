class Section < ActiveFedora::Base
  VALID_PARENT_CLASSES = [Paged, Section]
  include Node

  has_metadata 'descMetadata', type: SectionMetadata

  has_attributes :name, datastream: 'descMetadata', multiple: false

  validates :name, presence: true
end
