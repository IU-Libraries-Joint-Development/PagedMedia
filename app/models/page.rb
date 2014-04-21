# Copyright 2014 Indiana University

class Page < ActiveFedora::Base

  include Hydra::AccessControls::Permissions

  has_metadata 'descMetadata', type: PageMetadata
  
  belongs_to :paged, :property=> :is_part_of
  
  has_file_datastream 'pageImage'
  has_file_datastream 'pageOCR'

  has_attributes :logical_number, datastream: 'descMetadata',  multiple: false
  has_attributes :physical_number, datastream: 'descMetadata',  multiple: false
  has_attributes :text,  datastream: 'descMetadata', multiple: false
 
end
