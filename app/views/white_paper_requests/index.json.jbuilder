json.array!(@white_paper_requests) do |white_paper_request|
  json.extract! white_paper_request, :id, :name, :email, :number, :company_name, :white_paper_id
  json.url white_paper_request_url(white_paper_request, format: :json)
end
