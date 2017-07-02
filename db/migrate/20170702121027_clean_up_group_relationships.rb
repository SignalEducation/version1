class CleanUpGroupRelationships < ActiveRecord::Migration
  def change
    remove_column :home_pages, :group_id, :integer
    add_column :home_pages, :custom_file_name, :string, index: :true
    remove_column :groups, :background_colour, :string
    remove_column :subject_courses, :live, :boolean
    remove_column :subject_courses, :wistia_guid, :string
    remove_column :subject_courses, :mailchimp_guid, :string
    remove_column :subject_courses, :live_date, :datetime
    remove_column :subject_courses, :certificate, :boolean
    remove_column :subject_courses, :hotjar_guid, :string
    remove_column :subject_courses, :is_cpd, :boolean
    remove_column :subject_courses, :cpd_hours, :float
    remove_column :subject_courses, :cpd_pass_rate, :integer
    add_column :subject_courses, :group_id, :integer
    add_column :subject_courses, :quiz_pass_rate, :integer
  end
end
