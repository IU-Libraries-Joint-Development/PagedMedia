module FactoryHelpers
  module NodeHelpers
    def self.create_children(parent, child_class, number_of_children)
      children = Array.new
      child_factory = child_class.to_s.downcase.to_sym
      (0...number_of_children).each do |i|
        children[i] = FactoryGirl.create(child_factory, :unchecked, parent: parent.pid, prev_sib: i.zero? ? nil : children[i - 1].pid, **child_hash(parent, child_factory, i + 1))
      end
      next_child = nil
      children.reverse_each do |child|
        if next_child
	  child.next_sib = next_child.pid
          child.skip_linkage_update = true
	  child.save
	end
	next_child = child
      end
      parent.children = children.map { |c| c.pid }
      parent.skip_sibling_validation = true
      parent.skip_linkage_update = true
      parent.save
      parent.update_index
      children
    end
    def self.child_hash(parent, child_factory, num)
      values_hash = {}
      case child_factory
      when :page
        if parent.class == Section
          values_hash[:logical_number] = "Page #{parent.name}-#{num}"
	else
          values_hash[:logical_number] = "Page #{num}"
	end
      when :section
        if parent.class == Paged
	  values_hash[:name] = "Section #{num}"
	else
	  values_hash[:name] = "Subsection #{parent.name}-#{num}"
	end
      when :paged
        values_hash[:title] = "Volume #{num}"
      when :collection
        values_hash[:name] = "Subcollection #{num}"
      end
      values_hash
    end
  end
end
