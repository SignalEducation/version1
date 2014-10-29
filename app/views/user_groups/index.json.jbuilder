json.array!(@user_groups) do |user_group|
  json.extract! user_group, :id, :name, :description, :individual_student, :tutor, :content_manager, :blogger, :corporate_customer, :site_admin, :forum_manager, :subscription_required_at_sign_up, :subscription_required_to_see_content
  json.url user_group_url(user_group, format: :json)
end
