require 'spec_helper'

describe 'Credit Page' do
  
  it 'has content' do
    visit '/credits'
    page.should have_content('Credits')
  end

end