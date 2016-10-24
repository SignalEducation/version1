json.array!(@student_user_types) do |student_user_type|
  json.extract! student_user_type, :id, :name, :description, :subscription, :product_order
  json.url student_user_type_url(student_user_type, format: :json)
end
