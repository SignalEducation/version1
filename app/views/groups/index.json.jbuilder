json.array!(@groups) do |group|
  json.extract! group, :id, :name, :name_url, :active, :sorting_order, :description
  json.url group_url(group, format: :json)
end
