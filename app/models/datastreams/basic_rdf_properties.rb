module BasicRdfProperties
  extend ActiveSupport::Concern
  included do
    map_predicates do |map|
      map.title(in: RDF::DC) do |index|
        index.as :stored_searchable, :facetable
      end
      map.creator(in: RDF::DC) do |index|
        index.as :stored_searchable, :facetable
      end
      map.contributor(in: RDF::DC) do |index|
        index.as :stored_searchable, :facetable
      end
      map.description(in: RDF::DC) do |index|
      index.type :text
        index.as :stored_searchable
      end
      map.relation(in: RDF::DC)
      map.rights(in: RDF::DC) do |index|
        index.as :stored_searchable
      end
      map.publisher(in: RDF::DC) do |index|
        index.as :stored_searchable, :facetable
      end
      map.publisher_place(in: RDF::DC, to: "Location") do |index|
          index.as :stored_searchable, :facetable
      end

      map.created(in: RDF::DC)
      map.issued(in: RDF::DC) do |index|
        index.type :date
        index.as :stored_sortable
      end
      map.date(in: RDF::DC) do |index|
        index.type :date
        index.as :stored_sortable
      end
      map.subject(in: RDF::DC) do |index|
        index.as :stored_searchable, :facetable
      end
      map.language(in: RDF::DC) do |index|
        index.as :stored_searchable, :facetable
      end
      map.identifier(in: RDF::DC) do |index|
        index.as :stored_searchable
      end
      map.source(in: RDF::DC)
      map.coverage(in: RDF::DC)
      map.type(in: RDF::DC) do |index|
        index.as :stored_searchable
      end
    end
  end
end
