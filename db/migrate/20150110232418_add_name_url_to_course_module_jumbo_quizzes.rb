class AddNameUrlToCourseModuleJumboQuizzes < ActiveRecord::Migration
  def up
    add_column :course_module_jumbo_quizzes, :name_url, :string
    CourseModuleJumboQuiz.all.each do |q|
      q.update_attributes(name_url: q.name)
      print '.'
    end
  end

  def down
    remove_column :course_module_jumbo_quizzes, :name_url
  end
end
