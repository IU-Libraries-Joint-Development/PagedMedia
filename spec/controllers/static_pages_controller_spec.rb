require 'spec_helper'

describe 'Credit Page' do
  
  it 'has content' do
    visit '/credits'
    expect(page).to have_content('Credits')
  end

end
