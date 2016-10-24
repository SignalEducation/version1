json.array!(@subject_course_categories) do |subject_course_category|
  json.extract! subject_course_category, :id, :name, :payment_type, :active, :subdomain
  json.url subject_course_category_url(subject_course_category, format: :json)
end
