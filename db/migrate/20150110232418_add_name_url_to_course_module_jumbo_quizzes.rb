class AddNameUrlToCourseModuleJumboQuizzes < ActiveRecord::Migration[4.2]
  def up
    add_column :course_module_jumbo_quizzes, :name_url, :string
  end

  def down
    remove_column :course_module_jumbo_quizzes, :name_url
  end
end
