# A single page, representing an image, possibly with one or more alternate views.
#--
# Copyright 2014 Indiana University

class Page < ActiveFedora::Base
  has_metadata 'descMetadata', type: PageMetadata
  has_file_datastream 'pageImage'
  has_file_datastream 'pageOCR'

  has_attributes :logical_number, datastream: 'descMetadata',  multiple: false
  has_attributes :physical_number, datastream: 'descMetadata',  multiple: false
  has_attributes :text,  datastream: 'descMetadata', multiple: false

  # Setter for the image
  def image_file=(file)
    datastreams['pageImage'].content = file
    # TODO figure out and set content MIME type -- see ruby-filemagic
    # http://stackoverflow.com/questions/4600679/detect-mime-type-of-uploaded-file-in-ruby
  end

  # Getter for the image
  def image_file
    datastreams['pageImage'].content
  end

end
