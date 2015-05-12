json.array!(@marketing_categories) do |marketing_category|
  json.extract! marketing_category, :id
  json.url marketing_category_url(marketing_category, format: :json)
end
