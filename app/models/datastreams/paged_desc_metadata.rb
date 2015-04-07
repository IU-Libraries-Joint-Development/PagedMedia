class PagedDescMetadata < ActiveFedora::NtriplesRDFDatastream

  include BasicRdfProperties

  # Define custom properties not in basic vocabulary definitions
  map_predicates do |map|
    map.paged_struct(in: RDF::DC, to: "isPartOf") do |index|
      index.as :facetable
    end
  end

  def prefix(name)
    return "#{name}".to_sym
  end


end
