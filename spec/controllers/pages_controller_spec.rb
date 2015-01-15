require 'spec_helper'

describe PagesController do

  describe 'GET index' do
    it 'lists pages'
  end

  describe 'GET show' do
    it 'displays detail of a page'
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
    it 'stores a previous-page link' do
      apage = mock_model(Page, :prev_page= => nil, update: nil)
      expect(Page).to receive(:find).and_return(apage)
      expect(apage).to receive(:update).with('prev_page' => 'page:3')
      put :update, {
        page: {prev_page: 'page:3'},
        id: 'page:4'
      }
      assert_response :success
    end

    it 'stores a next-page link' do
      apage = mock_model(Page, :next_page= => nil, update: nil)
      expect(Page).to receive(:find).and_return(apage)
      expect(apage).to receive(:update).with('next_page' => 'page:5')
      put :update, {
        page: {next_page: 'page:5'},
        id: 'page:4'
      }
      assert_response :success
    end

    it 'stores a new image datastream'

    it 'stores a new OCR datastream'

    it 'stores a new XML datastream' do
      xml_upload = fixture_file_upload('/xml-test.xml', 'application/xml')

      apage = mock_model(Page,
                         xml_file: xml_upload,
                         :xml_file= => nil,
                         update: nil)

      expect(Page).to receive(:find).and_return(apage)
      expect(apage).to receive(:update).with('xml_file' => xml_upload)
      put :update, {
        page: {xml_file: xml_upload},
        id: '1'
      }
      assert_response :success
    end
  end

  describe 'DELETE destroy' do
    it 'destroys a Page'
  end

end
