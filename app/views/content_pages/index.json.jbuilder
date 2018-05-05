json.array!(@content_pages) do |content_page|
  json.extract! content_page, :id, :name, :public_url, :seo_title, :seo_description, :text_content, :h1_text, :h1_subtext, :nav_type, :footer_link
  json.url content_page_url(content_page, format: :json)
end
