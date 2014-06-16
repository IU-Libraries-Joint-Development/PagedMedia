# A binding of Page objects.
#--
# Copyright 2014 Indiana University.

class Paged < ActiveFedora::Base

  include Hydra::AccessControls::Permissions

  has_metadata 'descMetadata', type: PagedMetadataOaiDc, label: 'PMP PagedObject descriptive metadata'

  has_many :pages, :property=> :is_part_of

  has_attributes :title, datastream: 'descMetadata', multiple: false  # TODO update DC.title as well?
  has_attributes :creator, datastream: 'descMetadata', multiple: false
  has_attributes :type, datastream: 'descMetadata', multiple: false

end
