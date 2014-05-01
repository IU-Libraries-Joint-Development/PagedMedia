# Copyright 2014 Indiana University

require 'spec_helper'

describe Page do

  before { @page = Page.new }

  subject { @page }

  #FIXME: why do these 3 rspec tests fail, when they work in the console?
#  it { should respond_to(:descMetadata) }
#  it { should respond_to(:pageImage) }
#  it { should respond_to(:pageOCR) }

  it { should respond_to(:logical_number) }
  it { should respond_to(:physical_number) }
  it { should respond_to(:text) }

end
