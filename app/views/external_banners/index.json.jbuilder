json.array!(@external_banners) do |external_banner|
  json.extract! external_banner, :id, :name, :sorting_order, :active, :background_colour, :text_content
  json.url external_banner_url(external_banner, format: :json)
end
