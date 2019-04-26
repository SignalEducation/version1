class CreateExamBodies < ActiveRecord::Migration[4.2]
  def change
    create_table :exam_bodies do |t|
      t.string :name, index: true
      t.string :url

      t.timestamps null: false
    end
  end
end
