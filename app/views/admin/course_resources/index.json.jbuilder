json.array!(@course_resources) do |course_resource|
  json.extract! course_resource, :id, :name, :course_id, :description
  json.url course_resource_url(course_resource, format: :json)
end
