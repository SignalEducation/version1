json.array!(@subject_course_resources) do |subject_course_resource|
  json.extract! subject_course_resource, :id, :name, :subject_course_id, :description
  json.url subject_course_resource_url(subject_course_resource, format: :json)
end
