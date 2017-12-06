json.array!(@refunds) do |refund|
  json.extract! refund, :id, :stripe_guid, :charge_id, :stripe_charge_guid, :invoice_id, :subscription_id, :user_id, :manager_id, :amount, :reason, :status
  json.url refund_url(refund, format: :json)
end
