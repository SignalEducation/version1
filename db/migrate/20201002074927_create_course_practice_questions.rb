class CreateCoursePracticeQuestions < ActiveRecord::Migration[5.2]
  def change
    create_table :course_practice_questions do |t|
      t.string :name
      t.text :content
      t.integer :kind
      t.integer :estimated_time
      t.references :course_step, foreign_key: true, index: true
      t.datetime :destroyed_at

      t.timestamps
    end
  end
end
