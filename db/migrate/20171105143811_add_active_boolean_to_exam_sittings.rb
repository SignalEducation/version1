class AddActiveBooleanToExamSittings < ActiveRecord::Migration[4.2]
  def change
    add_column :exam_sittings, :active, :boolean, default: true
  end
end
