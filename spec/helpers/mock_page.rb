# RSpec::Mocks just doesn't do what I need, so do it the jmockit way (sort of).
# Copyright 2015 Indiana University

module ModelMocks

  class MockPage

    # Unique identifiers for each new instance.
    @@next_id = 0

    # Stores each new instance for find() to find
    @@instances = {}

    def initialize
      @my_id = 'MockPage:' + (@@next_id.to_s)
      @@next_id += 1

      @@instances[@my_id] = self

      @prev_sib = nil
      @next_sib = nil
    end

    def skip_sibling_validation=(s); end

    def pid; id; end
  
    def id; @my_id; end
  
    def id=(new_id); @my_id = new_id; end
  
    def prev_sib; @prev_sib; end
  
    def prev_sib=(p); @prev_sib = p; end
  
    def next_sib; @next_sib; end
  
    def next_sib=(n); @next_sib = n; end

    def update(*); true; end

    def valid?; true; end

    def save(*); true; end
  end

end
