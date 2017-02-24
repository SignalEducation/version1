json.array!(@course_modules) do |course_module|
  json.extract! course_module, :id, :name, :name_url, :description, :sorting_order, :estimated_time_in_seconds, :active
  json.url course_module_url(course_module, format: :json)
end
