if Rails.env.development?
  SubjectCourse.where(id: 1).first_or_create!(name: 'Course 1', name_url: 'course-1', sorting_order: 1, active: true, group_id: 1, 
  exam_body_id: 1, category_label: 'Test', survey_url: 'TEST_URL', quiz_pass_rate: 50, icon_label: 'LABEL', description: 'Course 1 description', default_number_of_possible_exam_answers: 4)
  SubjectCourse.where(id: 2).first_or_create(name: 'Course 2', name_url: 'course-2', sorting_order: 2, active: true, group_id: 1,
  exam_body_id: 1, category_label: 'Test', survey_url: 'TEST_URL', quiz_pass_rate: 50, icon_label: 'LABEL',  description: 'Course 2 description', default_number_of_possible_exam_answers: 4)
  SubjectCourse.where(id: 3).first_or_create(name: 'Course 3', name_url: 'course-3', sorting_order: 3, active: true, group_id: 1,
  exam_body_id: 1, category_label: 'Test', survey_url: 'TEST_URL', quiz_pass_rate: 50, icon_label: 'LABEL',  description: 'Course 3 description', default_number_of_possible_exam_answers: 4)
  SubjectCourse.where(id: 4).first_or_create(name: 'Course 4', name_url: 'course-4', sorting_order: 4, active: false, group_id: 1,
  exam_body_id: 1, category_label: 'Test', survey_url: 'TEST_URL', quiz_pass_rate: 50, icon_label: 'LABEL',  description: 'Course 4 description', default_number_of_possible_exam_answers: 3)
  SubjectCourse.where(id: 5).first_or_create(name: 'Course 5', name_url: 'course-5', sorting_order: 5, active: true, group_id: 1,
  exam_body_id: 1, category_label: 'Test', survey_url: 'TEST_URL', quiz_pass_rate: 50, icon_label: 'LABEL',  description: 'Course 5 description', default_number_of_possible_exam_answers: 4)
end