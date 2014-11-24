json.array!(@vat_codes) do |vat_code|
  json.extract! vat_code, :id, :country_id, :name, :label, :wiki_url
  json.url vat_code_url(vat_code, format: :json)
end
