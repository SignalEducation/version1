class CountFiledsToStudentExamTrackAndSubjectCourseUserLog < ActiveRecord::Migration
  def change
    add_column :student_exam_tracks, :count_of_quizzes_taken, :integer
    add_column :student_exam_tracks, :count_of_videos_taken, :integer
    add_column :subject_course_user_logs, :count_of_questions_correct, :integer
    add_column :subject_course_user_logs, :count_of_questions_taken, :integer
    add_column :subject_course_user_logs, :count_of_videos_taken, :integer
    add_column :subject_course_user_logs, :count_of_quizzes_taken, :integer
  end
end
