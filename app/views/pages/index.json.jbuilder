json.array!(@pages) do |page|
  json.extract! page, :id, :logical_number, :prev_page, :next_page
  json.url page_url(page, format: :json)
end
