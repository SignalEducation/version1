class CreateCbes < ActiveRecord::Migration[5.2]
  def change
    create_table :cbes do |t|
      t.string :name
      t.string :title
      t.text :desciption
      t.float :exam_time
      t.float :hard_time_limit
      t.integer :number_of_pauses_allowed
      t.references :exam_body
      t.integer :length_of_pauses

      t.timestamps
    end
  end
end
