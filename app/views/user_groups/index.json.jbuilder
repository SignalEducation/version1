json.array!(@user_groups) do |user_group|
  json.extract! user_group, :id, :name, :description, :individual_student, :tutor, :content_manager, :blogger, :site_admin
  json.url user_group_url(user_group, format: :json)
end
