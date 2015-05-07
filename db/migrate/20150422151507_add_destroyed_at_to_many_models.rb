class AddDestroyedAtToManyModels < ActiveRecord::Migration
  def change
    add_column :course_modules, :destroyed_at, :datetime, index: true
    add_column :course_module_jumbo_quizzes, :destroyed_at, :datetime, index: true
    add_column :course_module_elements, :destroyed_at, :datetime, index: true
    add_column :course_module_element_quizzes, :destroyed_at, :datetime, index: true
    add_column :course_module_element_videos, :destroyed_at, :datetime, index: true
    add_column :course_module_element_resources, :destroyed_at, :datetime, index: true
    add_column :quiz_contents, :destroyed_at, :datetime, index: true
    add_column :quiz_questions, :destroyed_at, :datetime, index: true
    add_column :quiz_answers, :destroyed_at, :datetime, index: true
  end
end
