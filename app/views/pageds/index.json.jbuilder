json.array!(@pageds) do |paged|
  json.extract! paged, :id, :title, :creator, :type
  json.url paged_url(paged, format: :json)
end
