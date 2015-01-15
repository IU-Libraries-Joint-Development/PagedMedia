require 'spec_helper'
require 'json'

describe PagedsController do

  before(:all) do
    @test_paged = create(:paged, :with_pages)
    @test_paged.update_index
  end

  context '#page' do
    it 'should return pid and image ds uri given an index integer' do
      get :pages, id: @test_paged.id, index: 1
      parsed = JSON.parse response.body
      expect(parsed['id']).to eq @test_paged.pages[1].pid
      expect(parsed['index']).to eq 1.to_s
      expect(parsed['ds_url']).to match /#{ERB::Util.url_encode(@test_paged.pages[1].pid)}\/datastreams\/pageImage\/content$/
    end 
  end 

  after(:all) do  
    @test_paged.pages.each {|page| page.delete }
    @test_paged.reload
    @test_paged.delete
  end

end

=begin
  describe 'GET index' do
    it 'lists Pageds'
  end

  describe 'GET show' do
    it 'displays detail of a Paged'
  end

  describe 'GET new' do
    it 'displays the create form'
  end

  describe 'GET edit' do
    it 'displays the edit form'
  end

  describe 'POST create' do
    it 'stores a new Page'
  end

  describe 'PUT update' do
    it 'updates the page somehow'
  end

  describe 'DELETE destroy' do
    it 'destroys a Paged'
  end

end
=end
