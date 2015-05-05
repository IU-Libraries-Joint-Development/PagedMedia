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

    describe 'allows reparenting action' do
      let!(:book_a) { FactoryGirl.create :paged, :with_pages, title: "Book A", number_of_pages: 3 }
      let!(:a_pages) { book_a.order_child_objects[0] }
      let!(:book_b) { FactoryGirl.create :paged, :with_pages, title: "Book B", number_of_pages: 3 }
      let!(:b_pages) { book_b.order_child_objects[0] }
      context 'removing a parent' do
        before(:each) do
          p2 = a_pages[1]
          p2.parent = nil; p2.prev_sib = nil; p2.next_sib = nil
          p2.save!
        end
        it 'updates the old parent' do
          book_a.reload
          expect(book_a.children).to eq [a_pages[0].pid, a_pages[2].pid]
        end
        it 'updates the old next_sib' do
          p3 = a_pages.last
          p3.reload
          expect(p3.prev_sib).to eq a_pages.first.pid
        end
        it 'updates the old prev_sib' do
          p1 = a_pages.first
          p1.reload
          expect(p1.next_sib).to eq a_pages.last.pid
        end
      end
      context 'changing a parent' do
        before(:each) do
          p2 = a_pages[1]
          p2.parent = book_b.pid; p2.prev_sib = b_pages[1].pid; p2.next_sib = b_pages[2].pid
          p2.save!
        end
        #FIXME: use shared examples for unlinking
        it 'updates the old parent' do
          book_a.reload
          expect(book_a.children).to eq [a_pages[0].pid, a_pages[2].pid]
        end
        it 'updates the old next_sib' do
          p3 = a_pages.last
          p3.reload
          expect(p3.prev_sib).to eq a_pages.first.pid
        end
        it 'updates the old prev_sib' do
          p1 = a_pages.first
          p1.reload
          expect(p1.next_sib).to eq a_pages.last.pid
        end
        it 'updates the new parent' do
          book_b.reload
          expect(book_b.children).to eq b_pages.map{|e| e.pid} + [a_pages[1].pid]
        end
        it 'updates the new prev_sib' do
          p2 = b_pages[1]
          p2.reload
          expect(p2.next_sib).to eq a_pages[1].pid
        end
        it 'updates tne new next_sib' do
          p3 = b_pages[2]
          p3.reload
          expect(p3.prev_sib).to eq a_pages[1].pid
        end
      end

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
