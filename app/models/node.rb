# A mixin providing navigational behavior in a tree of containers.  Sibling
# Nodes maintain local order through the prev_sib and next_sib references, which
# contain PIDs of Nodes.  A child Node remembers its parent by PID as its
# 'parent' attribute.  A parent Node has an array of its childrens' PIDs in the
# 'children' attribute.
#
# A Node may have no children (if it is a leaf node, such as a Page) or no
# parent (if it is at the top of the tree).
#--
# Copyright 2014 Indiana University

module Node

  VALID_PARENT_CLASSES = []
  VALID_CHILD_CLASSES = []

  def valid_parent_classes
    self.class.const_get(:VALID_PARENT_CLASSES)
  end

  def valid_child_classes
    self.class.const_get(:VALID_CHILD_CLASSES)
  end

  def self.included(including_class)
    including_class.const_set(:VALID_PARENT_CLASSES, VALID_PARENT_CLASSES) unless including_class.const_defined?(:VALID_PARENT_CLASSES)
    including_class.const_set(:VALID_CHILD_CLASSES, VALID_CHILD_CLASSES) unless including_class.const_defined?(:VALID_CHILD_CLASSES)

    including_class.class_eval do
      include Hydra::AccessControls::Permissions

      has_metadata 'nodeMetadata', type: NodeMetadata, label: 'PMP generic node metadata'

      # PID of my sibling immediately "before" me
      has_attributes :prev_sib, datastream: 'nodeMetadata', multiple: false
      # PID of my sibling which is immediately "after" me
      has_attributes :next_sib, datastream: 'nodeMetadata', multiple: false
      # PID of my parent node, if any
      has_attributes :parent, datastream: 'nodeMetadata', multiple: false
      # PIDs of my child Nodes
      has_attributes :children, datastream: 'nodeMetadata', multiple: true

      # skip_sibling_validation skips the custom validation
      attr_accessor :skip_sibling_validation
      attr_accessor :skip_linkage_update

      validate :validate_linkage, unless: :skip_sibling_validation
      validate :validate_children, unless: :skip_sibling_validation
      before_save :update_unlink, unless: :skip_linkage_update
      after_save :update_linkage, unless: :skip_linkage_update

      def self.valid_parent_classes
        const_get(:VALID_PARENT_CLASSES)
      end

      def self.valid_child_classes
        const_get(:VALID_CHILD_CLASSES)
      end
    end
  end

  # Check linkage with siblings and parent.  These are done together because
  # both depend on knowing the parent, and we economize on an expensive find().
  def validate_linkage
    # If there is no parent, then this node can't have siblings and we can't
    # check descent
    if parent.blank?
      unless prev_sib.blank?
        logger.error("#{self.class.name} #{pid}:  unowned node cannot have siblings")
        errors.add(:prev_sib, 'Unowned node cannot have siblings')
      end

      unless next_sib.blank?
        logger.error("#{self.class.name} #{pid}:  unowned node cannot have siblings")
        errors.add(:next_sib, 'Unowned node cannot have siblings')
      end

      return
    end

    my_parent = ActiveFedora::Base.find(parent, cast: true)

    # Check my parentage.
    # NOT OK if parent does not exist.
    if (my_parent.blank?)
      logger.error("#{self.class.name} #{pid}:  parent #{parent} does not exist")
      errors.add(:parent, 'parent node does not exist')
      return
    end

    # OK to already be parent's child.

    # NOT OK if parent class cannot be parent for this child
    if !(my_parent.class.in? valid_parent_classes)
      logger.error("#{self.class.name} #{pid}:  parent #{parent} class (#{my_parent.class}) is not in valid class list: #{valid_parent_classes})")
      errors.add(:parent, 'parent node is invalid class')
      return
    end

    # If parent has no children yet, then this node can't have siblings
    if (my_parent.children.size == 0)
      errors.add(:prev_sib, 'prev_sib must be empty') unless prev_sib.blank?
      errors.add(:next_sib, 'next_sib must be empty') unless next_sib.blank?
      return
    end

    # At least one child of my parent already exists.
    if (pid.blank?)
      # I am new so I must have a sibling.
      if (prev_sib.blank? && next_sib.blank?)
        errors.add(:base, 'must have one or both siblings if parent has children')
        return
      end
    else
      # I have been persisted, so I must either have a sibling or be my parent's only child.
      if (prev_sib.blank? && next_sib.blank? && (my_parent.children.size > 1 || my_parent.children.first != pid))
        errors.add(:base, 'must have one or both siblings if parent has children')
        return
      end
    end

    # Check that prev_sib is a child of my parent.
    unless prev_sib.blank?
      unless (my_parent.children.include?(prev_sib))
        logger.error("#{self.class.name} #{pid}:  #{prev_sib} not a child of #{my_parent.pid}")
        errors.add(:prev_sib, "#{prev_sib} not a child of #{my_parent.pid}")
        return
      end

      prev_sibling = ActiveFedora::Base.find(prev_sib, cast: true)
      if (prev_sibling.next_sib != next_sib) && (!pid.blank? && (prev_sibling.next_sib != pid))
        logger.error("#{self.class.name} #{pid}:  invalid next_sib #{next_sib}")
        errors.add(:next_sib, "invalid next_sib #{next_sib}")
        return
      end
    end

    # Check that next_sib is a child of my parent.
    unless next_sib.blank?
      unless (my_parent.children.include?(next_sib))
        logger.error("#{self.class.name} #{pid}:  #{next_sib} not a child of #{my_parent.pid}")
        errors.add(:next_sib, "#{next_sib} not a child of #{my_parent.pid}")
        return
      end

      next_sibling = ActiveFedora::Base.find(next_sib, cast: true)
      if (next_sibling.prev_sib != prev_sib) && (!pid.blank? && (next_sibling.prev_sib != pid))
        logger.error("#{self.class.name} #{pid}:  invalid prev_sib #{prev_sib}")
        errors.add(:prev_sib, "invalid prev_sib #{prev_sib}")
        return
      end
    end

  end

  # Ensure that my declared children exist and do not declare another parent.
  def validate_children
    children.each do |child|
      begin
        my_child = ActiveFedora::Base.find(child, cast: true)
      rescue
        my_child = nil
      end
      # NOT OK if child does not exist.
      if (my_child.nil?)
        logger.error("#{self.class.name} #{pid}:  child #{child} does not exist")
        errors.add(:child, 'child node does not exist')
        return
      # OK to already be this child's parent.
      # OK if child has no parent.
      # NOT OK if child has another parent.
      # TODO How to re-parent?
      elsif (!pid.blank? && (my_child.parent != pid))
        logger.error("#{self.class.name} #{pid}:  child #{my_child.pid} has another parent:  #{my_child.parent}")
        errors.add(:child, 'child has another parent')
        return
      end
    end
  end

  def update_unlink
    # Unlink myself from old previous sibling, if applicable
    unless prev_sib == prev_sib_was || prev_sib_was.blank?
      old_prev_sib = ActiveFedora::Base.find(prev_sib_was, cast: true)
      old_prev_sib.next_sib = next_sib_was
      old_prev_sib.skip_sibling_validation = true
      old_prev_sib.skip_linkage_update = true
      old_prev_sib.save
    end
    # Unlink myself from old next sibling, if applicable
    unless next_sib == next_sib_was || next_sib_was.blank?
      old_next_sib = ActiveFedora::Base.find(next_sib_was, cast: true)
      old_next_sib.prev_sib = prev_sib_was
      old_next_sib.skip_sibling_validation = true
      old_next_sib.skip_linkage_update = true
      old_next_sib.save
    end
    # Unlink myself from previous parent, if applicable
    unless parent == parent_was || parent_was.blank?
      old_parent = ActiveFedora::Base.find(parent_was, cast: true)
      old_sibs = old_parent.children
      old_sibs.delete(pid)
      old_parent.children = old_sibs
      old_parent.skip_sibling_validation = true
      old_parent.skip_linkage_update = true
      old_parent.save
    end
    #FIXME: unlink children?
  end

  def update_linkage
    # Link myself to previous sibling.
    unless prev_sib.blank?
      prev_sibling = ActiveFedora::Base.find(prev_sib, cast: true)
      if (prev_sibling.pid != pid)
        prev_sibling.next_sib = pid
        prev_sibling.skip_sibling_validation = true
        prev_sibling.skip_linkage_update = true
        prev_sibling.save
        logger.debug("Saving #{self.class.name} #{pid}:  prev_sib is #{prev_sib}")
      end
    end
    # Link myself to next sibling.
    unless next_sib.blank?
      next_sibling = ActiveFedora::Base.find(next_sib, cast: true)
      if (next_sibling.pid != pid)
        next_sibling.prev_sib = pid
        next_sibling.skip_sibling_validation = true
        next_sibling.skip_linkage_update = true
        next_sibling.save
        logger.debug("Saving #{self.class.name} #{pid}:  next_sib is #{next_sib}")
      end
    end
    # Link myself to my parent as a child.
    unless parent.blank?
      my_parent = ActiveFedora::Base.find(parent, cast: true)
      unless (my_parent.children.include?(pid))
        # This is really weird.  Multi-valued attributes have the usual array
        # operators but some of them do nothing.  The only way to augment one is
        # to augment a copy and assign the result back.  ?!?!
        my_parent.children = my_parent.children << pid
        my_parent.skip_sibling_validation = true
        my_parent.skip_linkage_update = true
        my_parent.save
      end
    end
    # Link my children to me as parent.
    children.each do |child|
      begin
        my_child = ActiveFedora::Base.find(child, cast: true)
      rescue
        my_child = nil
      end
      if (my_child && my_child.parent.blank? && (my_child.parent != pid))
        my_child.parent = pid
        my_child.skip_sibling_validation = true
        my_child.skip_linkage_update = true
        my_child.save
      end
    end

  end

  # Link this node into the "family tree".
  # These saves should be in a transaction, but does Fedora do transactions?
  #
  # The general plan is to:
  #
  # 1. sanity-check all "family" relationships (see validations);
  # 2. persist this object;
  # 3. update this object's relatives with relationships to this object.
  #
  # In that way, this object should be available to its relatives in its new
  # state for *their* sanity-checking as they persist themselves after update.
  # Any new relationships should already be sane before persisting, so there
  # should be no need to undo this object's state change due to problems with
  # relatives.
  #
  # '<tt>foo.save(unchecked: 1)</tt>' bypasses integrity checks.  Don't!  It's for this
  # method's internal use.
  def save(opts={})

    # Persist myself.
    logger.info("Saving #{self.class.name} #{pid}")
    begin
      return false if ! super()
    rescue RestClient::BadRequest => e
      logger.error(e.message)
      errors[:base] << e.message
      errors[:base] << 'Check for a damaged or invalid file'
      return false
    end

    # Success!
    logger.info("Saved #{self.class.name} #{pid}")
    logger.debug { self.inspect }
    true
  end

  def save!(opts={}) # Added to debug tests
    raise(ActiveFedora::RecordInvalid, self, caller) unless save(opts)
  end

  # Unlink this node from siblings and parent.
  # Raises OrphanError if this node has children.
  # FIXME: refactor to use update_unlink?
  def delete
    # Check for children.
    unless (children.empty?)
      logger.error("deleting #{self.class.name} #{pid}:  would leave orphans #{children.inspect}")
      raise OrphanError, children.inspect
    end

    # Load my siblings, if any.
    begin
      prev_sibling = ActiveFedora::Base.find(prev_sib, cast: true) unless prev_sib.blank?
    rescue ActiveFedora::ObjectNotFoundError => e
      logger.error("deleting #{self.class.name} #{pid}, missing prev_sib: #{e}")
    end

    begin
      next_sibling = ActiveFedora::Base.find(next_sib, cast: true) unless next_sib.blank?
    rescue ActiveFedora::ObjectNotFoundError => e
      logger.error("deleting #{self.class.name} #{pid}, missing next_sib: #{e}")
    end

    # Unlink from previous sibling.
    if (prev_sibling)
      prev_sibling.next_sib = next_sibling ? next_sibling.pid : nil
      prev_sibling.skip_sibling_validation = true
      prev_sibling.save(unchecked: 1)
    end

    # Unlink from next sibling.
    if (next_sibling)
      next_sibling.prev_sib = prev_sibling ? prev_sibling.pid : nil
      next_sibling.skip_sibling_validation = true
      next_sibling.save(unchecked: 1)
    end

    # Load my parent, if any.
    begin
      my_parent = ActiveFedora::Base.find(parent, cast: true) unless parent.blank?
    rescue ActiveFedora::ObjectNotFoundError => e
      logger.error("deleting #{self.class.name} #{pid}, missing parent #{parent}: #{e}")
    end

    # Unlink from parent.
    if (my_parent)
      my_sibs = my_parent.children
      my_sibs.delete(pid)
      my_parent.children = my_sibs
      my_parent.skip_sibling_validation = true
      my_parent.save(unchecked: 1)
    end

    logger.info("Deleting #{self.class.name} #{pid}")
    super
    logger.info("Deleted #{self.class.name} #{pid}")
  end


  # Method returns ordered children objects array and false
  # Or incomplete ordered children objects array and an error message
  # FIXME: how should we do error-checking in methods that call this?
  def order_child_objects()
    ordered_children = Array.new
    error = false
    # Get first child and all child ids
    first_child = false
    next_child = false
    child_ids = Array.new
    # Check for multiple first children
    self.children.each do |child|
      child_ids << child
      my_child = ActiveFedora::Base.find(child, cast: true)
      next unless my_child.prev_sib.blank?
      unless first_child
        first_child = my_child
      else
        error = "Multiple First Children"
        return [ordered_children, error]
      end
    end
    # Check for no first child
    if first_child
      next_child = first_child
    else
      error = "No First Child Found"
      return [ordered_children, error]
    end
    my_children = Array.new
    while next_child do
      ordered_children << next_child
      np_id = next_child.next_sib
      unless np_id.blank?
        if my_children.include?(np_id)
          # Check for infinite loop
          error = "Infinite loop of children"
          next_child = false
        elsif child_ids.include?(np_id)
          # Find next child
          my_children << np_id
          next_child = ActiveFedora::Base.find(np_id, cast: true)
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
    return [ordered_children, error]
  end

  # Method returns ordered children pids array and false
  # Or unordered children pids array and an error message
  def order_children()
    ordered_children = order_child_objects
    # Return unordered list if error occurs
    return [self.children, ordered_children[1]] if ordered_children[1]
    return [ordered_children[0].collect! {|child| child.pid}, false]
  end

  # Returns values hash used in descendent/ancestry list methods
  def to_hash(**values)
    {id: self.pid}.merge(additional_hash_values).merge(values)
  end

  # Additional values to include in hash used by descendent/ancestry list methods
  # Override in a model to provide model-specific values
  def additional_hash_values
    {}
  end

  # Returns an array of descendent objects, NOT searching children of matching nodes
  # If no class_filter is passed, all immediate descendents will match, so only children are returned
  # If filtering on a class, a given line of descendents is searched until a match is found
  def list_descendent_objects(class_filter = nil)
    descendent_list = []
    self.order_child_objects[0].each do |child|
      if class_filter.nil? || child.class == class_filter
        descendent_list << child
      elsif child.children.any?
        descendent_list += child.list_descendent_objects(class_filter)
      end
    end
    descendent_list
  end

  # As for list_descendent_objects, but returns array of object hashes with index value added
  def list_descendents(class_filter = nil)
    descendent_list = []
    list_descendent_objects(class_filter).each_with_index do |object, index|
      descendent_list << object.to_hash(index: index)
    end
    descendent_list
  end

  # Returns array of descendent objects, matching by class, AND their matching children
  # If no class_filter is passed, all descendents will match, so the entire descendent tree is returned
  # If filtering on a class, a matching child will be listed, as well as all of its matching descendents, recursively
  def list_descendent_objects_recursive(class_filter = nil)
    descendent_list = []
    if class_filter.nil? || class_filter.in?(valid_child_classes)
      self.order_child_objects[0].each do |child|
        if class_filter.nil? || child.class == class_filter
          descendent_list << child
          descendent_list += child.list_descendent_objects_recursive(class_filter) if child.children.any?
        end
      end
    end
    descendent_list
  end

  # As for list_descendent_objects_recursive, but returns array of object hashes
  def list_descendents_recursive(class_filter = nil)
    list_descendent_objects_recursive(class_filter).collect { |x| x.to_hash }
  end

  # Returns ancestor object of specified class, searching ancestry until first match is found
  # If no class_filter is passed, immediate parent is returned
  # If filtering on a class, ancestry line is searched until a match is found
  def ancestor_object_of_class(class_filter = nil)
    if parent.blank?
      nil
    else
      ancestor = ActiveFedora::Base.find(parent, cast: true)
      if class_filter.nil? || ancestor.class == class_filter
        ancestor
      else
        ancestor.ancestor_object_of_class(class_filter)
      end
    end
  end

  # As for ancestor_object_of_class, but returns only the pid
  def ancestor_of_class(class_filter = nil)
    ancestor = ancestor_object_of_class(class_filter)
    ancestor ? ancestor.pid : nil
  end

  # Returns array with hash values for each ancestor of (optionally) specified class
  # If no class_filter is specified, all ancestors are returned
  # If filtering on a class, search stops as soon as an ancestor fails to match
  # Array values start with oldest included ancestor
  def list_ancestor_objects(class_filter = nil)
    ancestor_list = []
    unless parent.blank? || (class_filter && !class_filter.in?(valid_parent_classes))
      ancestor = ActiveFedora::Base.find(parent, cast: true)
      if class_filter.nil? || ancestor.class == class_filter
        ancestor_list.unshift(ancestor)
        ancestor_list = ancestor.list_ancestor_objects(class_filter) + ancestor_list if ancestor.parent
      end
    end
    ancestor_list
  end

  # As for list_ancestor_objects, but returns array of hash values
  def list_ancestors(class_filter = nil)
    list_ancestor_objects(class_filter).collect { |x| x.to_hash }
  end

  # Takes a nested array of hashes with id, children values
  # Recursively changes relationships
  def restructure_children(child_hash_array)
    new_children = child_hash_array.map { |e| e["id"] }
    new_child_objects = new_children.map { |pid| ActiveFedora::Base.find(pid, cast: true) }
    if self.children != new_children
      self.children = new_children
      self.skip_sibling_validation = true
      self.skip_linkage_update = true
      self.save
      prev_child = nil
      new_child_objects.each do |child|
        prev_child.next_sib = child.pid unless prev_child.nil?
        child.parent = self.pid
        child.prev_sib = (prev_child ? prev_child.pid : nil)
        child.next_sib = nil
        prev_child = child
      end
      new_child_objects.each do |child|
        child.skip_sibling_validation = true
        child.skip_linkage_update = true
        child.save
      end
    end
    new_child_objects.each_with_index do |child, index|
      nested_array = child_hash_array[index]["children"]
      child.restructure_children(nested_array) if nested_array
    end
    self.update_index
  end

end
