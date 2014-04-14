json.array!(@pages) do |page|
  json.extract! page, :id, :logical_number, :physical_number
  json.url page_url(page, format: :json)
end
