json.array!(@currencies) do |currency|
  json.extract! currency, :id, :iso_code, :name, :leading_symbol, :trailing_symbol, :active, :sorting_order
  json.url currency_url(currency, format: :json)
end
