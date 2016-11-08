json.array!(@mock_exams) do |mock_exam|
  json.extract! mock_exam, :id, :subject_course_id, :product_id, :name, :sorting_order
  json.url mock_exam_url(mock_exam, format: :json)
end
