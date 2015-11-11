json.array!(@white_papers) do |white_paper|
  json.extract! white_paper, :id, :title, :description
  json.url white_paper_url(white_paper, format: :json)
end
