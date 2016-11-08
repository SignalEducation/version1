json.array!(@exam_sittings) do |exam_sitting|
  json.extract! exam_sitting, :id, :name, :subject_course_id, :date
  json.url exam_sitting_url(exam_sitting, format: :json)
end
