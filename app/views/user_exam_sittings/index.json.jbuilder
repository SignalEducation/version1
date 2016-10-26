json.array!(@user_exam_sittings) do |user_exam_sitting|
  json.extract! user_exam_sitting, :id, :user_id, :exam_sitting_id, :subject_course_id, :date
  json.url user_exam_sitting_url(user_exam_sitting, format: :json)
end
