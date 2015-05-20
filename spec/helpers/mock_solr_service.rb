# Copyright 2015 Indiana University.

module ServiceMocks

  ## Pretend to be a Solr service connection holder
  class MockSolrService
    include Singleton

    def initialize
      @connection = Connection.new
    end

    # instance() is provided by Singleton
    
    def conn
      # return something that responds to 'select'
      @connection
    end

    ## Set "index content" to be returned by conn.select
    def index=(content)
      @connection.index = content
    end

    private

    ## Pretend to be a connection to a Solr service
    class Connection

      def commit
        # do nothing
      end

      def delete_by_query(query)
        # do nothing
      end

      def select(**args)
        selected = {'response' => {'num_found' => nil, 'docs' => [ {'pages_ss' => nil} ] } }
        selected['response']['num_found'] = -1 # TODO Count them
        selected['response']['docs'][0]['pages_ss'] = @index_content
        return selected
      end

      ## Set "index content" to be returned by select
      def index=(content)
        @index_content = content
      end
      
    end

  end

end