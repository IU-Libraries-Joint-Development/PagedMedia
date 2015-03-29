class Section < ActiveFedora::Base
  VALID_PARENT_CLASSES = [Paged, Section]
  VALID_CHILD_CLASSES = [Section, Page]
  include Node

  has_metadata 'descMetadata', type: SectionMetadata

  has_attributes :name, datastream: 'descMetadata', multiple: false

  validates :name, presence: true

  # Additional values to include in hash used by descendent/ancestry list methods
  def additional_hash_values
    {name: name}
  end

end
