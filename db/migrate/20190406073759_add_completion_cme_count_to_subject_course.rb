class AddCompletionCmeCountToSubjectCourse < ActiveRecord::Migration[5.2]
  def change
    add_column :groups, :short_description, :string
    add_column :home_pages, :seo_no_index, :boolean, null: false, default: false
    add_column :subject_courses, :completion_cme_count, :integer
    add_column :subject_courses, :release_date, :date

    rename_column :subject_courses, :additional_text_label, :icon_label

    remove_column :subject_courses, :question_count, :integer
    remove_column :subject_courses, :best_possible_first_attempt_score, :float
    remove_column :subject_courses, :total_video_duration, :float
    remove_column :subject_courses, :total_estimated_time_in_seconds, :float
    remove_column :subject_courses, :short_description, :string
    remove_column :subject_courses, :external_url_name, :string
    remove_column :subject_courses, :external_url, :string
    remove_column :subject_courses, :email_content, :string
  end
end
