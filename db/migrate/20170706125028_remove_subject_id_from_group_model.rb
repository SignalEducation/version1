class RemoveSubjectIdFromGroupModel < ActiveRecord::Migration[4.2]
  def change
    remove_column :groups, :subject_id, :integer
  end
end
