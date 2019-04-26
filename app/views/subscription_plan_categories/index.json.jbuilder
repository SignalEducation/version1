json.array!(@subscription_plan_categories) do |subscription_plan_category|
  json.extract! subscription_plan_category, :id, :name, :available_from, :available_to, :guid
  json.url subscription_plan_category_url(subscription_plan_category, format: :json)
end
