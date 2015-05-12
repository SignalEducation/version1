class AddNameUrlToCourseModuleJumboQuizzes < ActiveRecord::Migration
  def up
    add_column :course_module_jumbo_quizzes, :name_url, :string
    CourseModuleJumboQuiz.unscoped.all.each do |q|
      #q.name_url = q.name
      #q.save(callbacks: false, validations: false)
      q.update_column(:name_url, q.name)
      print '.'
    end
  end

  def down
    remove_column :course_module_jumbo_quizzes, :name_url
  end
end
