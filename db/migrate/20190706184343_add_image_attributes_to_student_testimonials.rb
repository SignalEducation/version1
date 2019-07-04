class AddImageAttributesToStudentTestimonials < ActiveRecord::Migration[5.2]
  def up
    add_attachment :student_testimonials, :image
  end

  def down
    remove_attachment :student_testimonials, :image
  end
end
