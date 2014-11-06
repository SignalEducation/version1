json.array!(@subscription_plans) do |subscription_plan|
  json.extract! subscription_plan, :id, :available_to_students, :available_to_corporates, :all_you_can_eat, :payment_frequency_in_months, :currency_id, :price, :available_from, :available_to, :stripe_guid, :trial_period_in_days
  json.url subscription_plan_url(subscription_plan, format: :json)
end
