class AddFormHeadingTextAndLogoToExamBodies < ActiveRecord::Migration[5.2]
  def change
    add_column :exam_bodies, :logo_image, :string
    add_column :exam_bodies, :registration_form_heading, :string
    add_column :exam_bodies, :login_form_heading, :string
  end
end
