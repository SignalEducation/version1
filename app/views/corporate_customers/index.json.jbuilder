json.array!(@corporate_customers) do |corporate_customer|
  json.extract! corporate_customer, :id, :organisation_name, :address, :country_id, :payments_by_card, :stripe_customer_guid
  json.url corporate_customer_url(corporate_customer, format: :json)
end
