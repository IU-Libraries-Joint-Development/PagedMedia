# A binding of Page objects.
#--
# Copyright 2014 Indiana University.

class Paged < ActiveFedora::Base

  has_metadata 'DC', type: PagedMetadataDublinCore

  has_attributes :title, datastream: 'DC', multiple: false
  has_attributes :creator, datastream: 'DC', multiple: false
end
