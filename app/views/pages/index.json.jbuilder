json.array!(@pages) do |page|
  json.extract! page, :id, :logical_number, :prev_sib, :next_sib
  json.url page_url(page, format: :json)
end
