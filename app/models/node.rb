# A node in a tree of containers.  Sibling Nodes maintain local order through
# the prev_sib and next_sib references, which contain PIDs of Nodes.  A child
# Node remembers its parent by PID.  A parent Node has an array of its childrens'
# PIDs.
#
# A Node may have no children (if it is a leaf node, such as a Page) or no
# parent (if it is at the top of the tree.
#--
# Copyright 2014 Indiana University

class Node < ActiveFedora::Base

  include Hydra::AccessControls::Permissions

  has_metadata 'nodeMetadata', type: NodeMetadata, label: 'PMP generic node metadata'

  has_attributes :prev_sib, datastream: 'nodeMetadata', multiple: false
  has_attributes :next_sib, datastream: 'nodeMetadata', multiple: false
  has_attributes :parent, datastream: 'nodeMetadata', multiple: false
  has_attributes :children, datastream: 'nodeMetadata', multiple: true

  class ChildArray < Array
    def [](i)
      return _children[i]
    end

    def []=
      # TODO
    end
  end

#  def children
#    kids = ChildArray.new()
#    _children.each do |child|
#      kids << Node.find(child)
#    end
#    return kids
#  end

  # skip_sibling_validation both skips the custom validation and runs an unchecked save
  attr_accessor :skip_sibling_validation
  validate :validate_has_required_siblings, unless: :skip_sibling_validation

  # A link is "unset" if it is nil or an empty String
  def unset?(attribute)
    attribute.nil? || attribute.empty?
  end

  # If the parent is empty, sibling pointers should be nil, otherwise at least
  # one must be non-nil.
  def validate_has_required_siblings
    return if parent.nil?
    my_parent = Node.find(parent)

    # Parent has no children yet, so this page can't have siblings
    if (my_parent.children.size == 0)
      errors.add(:prev_sib, 'prev_sib must be empty') if !unset?(prev_sib)
      errors.add(:next_sib, 'next_sib must be empty') if !unset?(next_sib)
      return
    end

    # At least one child of my parent already exists.  Must have at least one
    # sibling unless the one child is this one (we are updating, not creating).
    if (unset?(prev_sib) && unset?(next_sib) &&
        ((my_parent.children.size > 1) || (my_parent.children.first.pid != pid)))
      errors[:base] << 'must have one or both siblings if parent has children'
    end
  end


  # Link this node into the "family tree".
  # These saves should be in a transaction, but does Fedora do transactions?
  #
  # The general plan is to:
  #
  #  1) sanity-check all "family" relationships;
  #  2) persist this object;
  #  3) update this object's relatives with relationships to this object.
  #
  # In that way, this object should be available to its relatives in its new
  # state for *their* sanity-checking as they persist themselves after update.
  # Any new relationships should already be sane before persisting, so there
  # should be no need to undo this object's state change due to problems with
  # relatives.
  #
  # 'foo.save(unchecked: 1)' bypasses integrity checks.  Don't!  It's for this
  # method's internal use.
  def save(opts={})

    if (opts.has_key?(:unchecked))
      return super()
    end

    # Get a copy of my supposed parent.
    my_parent = Node.find(parent) if !parent.nil?

    # Check that prev_sib is a child of my parent.
    if (!unset?(prev_sib))
      found = false
      if (!parent.nil?)
        my_parent.children.each do |a_child|
          found = true if a_child.pid == prev_sib
        end
        if !found
          errors.add(:prev_sib, "#{prev_sib} not in #{my_parent.pid}")
          return false
        end
      else
        errors.add(:prev_sib, 'Unowned node cannot have siblings')
        return false
      end

      prev_sibling = find(prev_sib)
      if (prev_sibling.next_sib != next_sib) && (prev_sibling.next_sib != pid)
        errors.add(:next_sib, 'invalid')
        return false
      end
    end

    # Check that next_sib is a child of my parent.
    if (!unset?(next_sib))
      found = false
      if (!parent.nil?)
        my_parent.children.each do |a_child|
          found = true if a_child.pid == next_sib
        end
        if !found
          errors.add(:next_sib, "#{next_sib} not in #{my_parent.pid}")
          return false
        end
      else
        errors.add(:next_sib, 'Unowned node cannot have siblings')
        return false
      end

      next_sibling = find(next_sib)
      if (next_sibling.prev_sib != prev_sib) && (next_sibling.prev_sib != pid)
        errors.add(:prev_sib, 'invalid')
        return false
      end
    end

    # TODO Check my parentage.
    # does parent exist?
    # OK to already be parent's child.

    # TODO Check my children.
    # OK to already be this child's parent.
    # OK if child has no parent.
    # NOT OK if child has another parent.
    # (How to re-parent?)

    # Persist myself.
    begin
      return false if ! super()
    rescue RestClient::BadRequest => e
      errors[:base] << e.message
      errors[:base] << 'Check for a damaged or invalid file'
      return false
    end

    # Link myself to previous sibling.
    if (!unset?(prev_sib))
      prev_sibling = find(prev_sib)
      prev_sibling.next_sib = pid
      prev_sibling.save(unchecked: 1)
    end

    # Link myself to next sibling.
    if (!unset?(next_sib))
      next_sibling = find(next_sib)
      next_sibling.prev_sib = pid
      next_sibling.save(unchecked: 1)
    end

    # TODO Link myself to my parent.

    # TODO Link myself to my children.

    # Success!
    true
  end

  # Unlink this node from siblings and parent.
  def delete
    # TODO check for children.

    # Load my siblings, if any.
    begin
      prev_sibling = find(prev_sib) if (!unset?(prev_sib))
    rescue ActiveFedora::ObjectNotFoundError => e
      logger.error("deleting #{pid}, missing prev_sib: #{e}")
    end

    begin
      next_sibling = find(next_sib) if (!unset?(next_sib))
    rescue ActiveFedora::ObjectNotFoundError => e
      logger.error("deleting #{pid}, missing next_sib: #{e}")
    end

    # Unlink from previous sibling.
    if (prev_sibling)
      prev_sibling.next_sib = next_sibling ? next_sibling.pid : nil
      prev_sibling.save(unchecked: 1)
    end

    # Unlink from next sibling.
    if (next_sibling)
      next_sibling.prev_sib = prev_sibling ? prev_sibling.pid : nil
      next_sibling.save(unchecked: 1)
    end

    super
  end

  # Method returns ordered children and false
  # Or unordered children and an error message
  def order_children()
    ordered_children = Array.new
    error = false
    # Get first child and all child ids
    first_child = false
    next_child = false
    child_ids = Array.new
    self.children.each do |child|
      child_ids << child.pid
      next if child.prev_sib != nil && child.prev_sib != ''
      # Check for multiple first children
      if !first_child
        first_child = child
      else
        error = "Multiple First Children"
        return [self.children, error]
      end
    end
    if first_child
      next_child = first_child
    else
      # Check for no first child
      error = "No First Child Found"
      return [self.children, error]
    end
    my_children = Array.new
    while next_child do
      ordered_children << next_child
      np_id = next_child.next_sib
      if  np_id != nil && np_id != ''
        if my_children.include?(np_id)
          # Check for infinite loop
          error = "Infinite loop of children"
          next_child = false
        elsif child_ids.include?(np_id)
          # Find next child
          my_children << np_id
          next_child = Node.find(np_id)
        else
          # Node has no parent
          error = "Node not Found in Listing - " + np_id.to_s
          next_child = false
        end
      else
        next_child = false
      end
    end
    # Check if all children are included
    if !error && ordered_children.count < self.children.count
      error = "Children Missing From List"
    end
    # Return unordered list if error occurs
    return [self.children, error] if error
    return [ordered_children, error]
  end

end
