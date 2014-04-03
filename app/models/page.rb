# Copyright 2014 Indiana University

class Page < ActiveFedora::Base
  has_metadata 'descMetadata', type: PageMetadata
  has_file_datastream 'pageImage'
  has_file_datastream 'pageOCR'

  has_attributes :logical_number, datastream: 'descMetadata',  multiple: false
  has_attributes :physical_number, datastream: 'descMetadata',  multiple: false
  has_attributes :text,  datastream: 'descMetadata', multiple: false
 
end
