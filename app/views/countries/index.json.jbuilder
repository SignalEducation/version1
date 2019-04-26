json.array!(@countries) do |country|
  json.extract! country, :id, :name, :iso_code, :country_tld, :sorting_order, :in_the_eu, :currency_id
  json.url country_url(country, format: :json)
end
