json.array!(@home_pages) do |home_page|
  json.extract! home_page, :id, :seo_title, :seo_description, :subscription_plan_category_id, :public_url
  json.url home_page_url(home_page, format: :json)
end
