# RSpec::Mocks just doesn't do what I need, so do it the jmockit way (sort of).
# Copyright 2015 Indiana University

module ModelMocks

  class MockPaged

    # Unique identifiers for each new instance.
    @@next_id = 0

    # Stores each new instance for find() to find
    @@instances = {}

    # Constructor

    def initialize
      @my_id = 'MockPaged:' + (@@next_id.to_s)
      @@next_id += 1

      @@instances[@my_id] = self

      @prev_sib = nil
      @next_sib = nil
      @children = []

      @title = @my_id
      @persisted = false
    end

    # Class methods

    def MockPaged.all; @@instances.values; end

    def MockPaged.count; @@instances.length; end

    def MockPaged.find(id); @@instances[id]; end

    def MockPaged.model_name; ActiveModel::Name.new(ModelMocks::MockPaged, nil, 'Paged'); end

    # Instance methods

    def children; @children; end

    def title; @title; end

    def title=(t); @title = t; end

    def pid; id; end

    def id; @my_id; end

    def id=(new_id); @my_id = new_id; end

    def prev_sib; @prev_sib; end

    def prev_sib=(p); @prev_sib = p; end

    def next_sib; @next_sib; end

    def next_sib=(n); @next_sib = n; end

    def restructure_children(struct); end

    def update_index; end

    def skip_sibling_validation=; end

    # ActiveRecord instance methods

    def destroy; @@instances.delete(@my_id); end

    def new_record?; !@persisted; end

    def persisted?; @persisted; end

    def save(*); @persisted = true; true; end

    def update(*); true; end

    def valid?; true; end

  end

end