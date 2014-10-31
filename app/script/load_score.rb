require File.join('.', 'spec', 'spec_helper.rb')

describe 'Loading objects' do

  before(:all) do
    @test_paged = create(:score_with_pages)
  end

  context 'Loading an example score' do
    it 'should create a score and load pages' do
      @test_paged.pages.each {|page|
        p 'Loaded ' + page.logical_number
      }
    end
  end 
end
