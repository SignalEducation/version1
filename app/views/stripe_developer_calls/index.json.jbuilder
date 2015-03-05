json.array!(@stripe_developer_calls) do |stripe_developer_call|
  json.extract! stripe_developer_call, :id, :user_id, :params_received, :prevent_delete
  json.url stripe_developer_call_url(stripe_developer_call, format: :json)
end
