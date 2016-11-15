json.array!(@subject_courses) do |subject_course|
  json.extract! subject_course, :id, :name, :name_url, :sorting_order, :active, :live, :wistia_guid, :tutor_id, :cme_count, :video_count, :quiz_count, :question_count, :description, :short_description, :mailchimp_guid
  json.url subject_course_url(subject_course, format: :json)
end
