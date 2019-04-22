class AddConstructedResponseIntroTextToExamBodies < ActiveRecord::Migration[5.2]
  def change
    add_column :exam_bodies, :constructed_response_intro_heading, :string
    add_column :exam_bodies, :constructed_response_intro_text, :text
  end
end
