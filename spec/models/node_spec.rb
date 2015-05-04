# Copyright 2015 Indiana University

describe Node, type: :model do

  let!(:page) { FactoryGirl.create :page, prev_sib: '', next_sib: '' }
  let!(:paged) { FactoryGirl.create :test_paged }

  describe 'enforces linkage rules:' do

    it 'adds itself to its parent' do
      page.parent = paged.pid
      page.save
      paged.reload # paged didn't see page linkage yet
      expect(paged.children.size).to eq 1
    end

    it 'must have no siblings if it is the only child of its parent' do
      page.parent = paged.pid
      page.prev_sib = 'too:many'
      expect(page.save).to be_false
    end

    it 'must have one or both siblings if it is not the only child of its parent' do
      page.prev_sib = ''
      page.logical_number = '1'
      page.parent = paged.pid
      expect(page.save).to be_true
      paged.save

      page2 = FactoryGirl.create(:page, logical_number: '2', prev_sib: '', next_sib: '')
      paged.reload
      page2.parent = paged.pid
      expect(page2.save).to be_false
    end

    it 'links itself between its siblings when saved' do
      page1, page2, page3 = make_a_book

      # page1, page2, page3 should now be linked in that order
      page1.reload
      page2.reload
      page3.reload
      expect(page1.prev_sib).to be_empty
      expect(page1.next_sib).to eql page2.pid
      expect(page2.prev_sib).to eql page1.pid
      expect(page2.next_sib).to eql page3.pid
      expect(page3.prev_sib).to eql page2.pid
      expect(page3.next_sib).to be_empty
    end

    it 'unlinks itself and links its siblings when deleted' do
      page1, page2, page3 = make_a_book

      page2.delete

      page1.reload
      expect(page1.prev_sib).to be_empty
      expect(page1.next_sib).to eql(page3.pid)

      page3.reload
      expect(page3.prev_sib).to eql(page1.pid)
      expect(page3.next_sib).to be_empty
    end
  end

  # Populate paged with three linked pages, and return references to them.
  def make_a_book
    # First page, can have no siblings
    page1 = FactoryGirl.create(:page, logical_number: '1', parent: paged.pid,
      prev_sib: '',
      next_sib: '')

    # Second page, must have at least one sibling
    page3 = FactoryGirl.create(:page, logical_number: '3', parent: paged.pid,
      prev_sib: page1.pid, # follows first page
      next_sib: '')

    # Third page, inserts itself between first and second
    page2 = FactoryGirl.create(:page, logical_number: '2', parent: paged.pid,
      prev_sib: page1.pid, # follows first page
      next_sib: page3.pid) # precedes second page

    return [ page1, page2, page3 ]
  end

end