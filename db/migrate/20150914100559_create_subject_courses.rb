class CreateSubjectCourses < ActiveRecord::Migration
  def change
    create_table :subject_courses do |t|
      t.string :name, index: true
      t.string :name_url
      t.integer :sorting_order
      t.boolean :active, default: false, null: false
      t.boolean :live, default: false, null: false
      t.string :wistia_guid, index: true
      t.integer :tutor_id, index: true
      t.integer :cme_count
      t.integer :video_count
      t.integer :quiz_count
      t.integer :question_count
      t.text :description
      t.string :short_description
      t.string :mailchimp_guid
      t.string :forum_url

      t.timestamps null: false
    end
  end
end
