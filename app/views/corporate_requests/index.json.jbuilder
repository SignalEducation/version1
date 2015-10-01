json.array!(@corporate_requests) do |corporate_request|
  json.extract! corporate_request, :id, :name, :title, :company, :email, :phone_number, :website, :message
  json.url corporate_request_url(corporate_request, format: :json)
end
