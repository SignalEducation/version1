class CreateStudentTestimonials < ActiveRecord::Migration[5.2]
  def change
    create_table :student_testimonials do |t|
      t.integer :home_page_id, index: true
      t.integer :sorting_order
      t.text :text
      t.string :signature

      t.timestamps
    end
  end
end
