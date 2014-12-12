class ReorganizeCmeModels < ActiveRecord::Migration
  def up
    remove_column :course_module_elements, :course_module_element_video_id
    remove_column :course_module_elements, :course_module_element_quiz_id
    remove_column :course_module_element_videos, :name
    remove_column :course_module_element_videos, :description
    remove_column :course_module_element_videos, :tutor_id
    remove_column :course_module_element_videos, :run_time_in_seconds
    remove_column :course_module_element_quizzes, :name
    remove_column :course_module_element_quizzes, :preamble
    remove_column :course_module_element_quizzes, :expected_time_in_seconds
  end

  def down
    add_column :course_module_elements, :course_module_element_video_id, :integer
    add_column :course_module_elements, :course_module_element_quiz_id, :integer
    add_column :course_module_element_videos, :name, :string
    add_column :course_module_element_videos, :description, :text
    add_column :course_module_element_videos, :tutor_id, :integer
    add_column :course_module_element_videos, :run_time_in_seconds, :integer
    add_column :course_module_element_quizzes, :name, :string
    add_column :course_module_element_quizzes, :preamble, :text
    add_column :course_module_element_quizzes, :expected_time_in_seconds, :integer
  end
end
