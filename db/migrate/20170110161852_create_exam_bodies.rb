class CreateExamBodies < ActiveRecord::Migration
  def change
    create_table :exam_bodies do |t|
      t.string :name, index: true
      t.string :url

      t.timestamps null: false
    end
  end
end
