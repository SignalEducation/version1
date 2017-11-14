class AddActiveBooleanToExamSittings < ActiveRecord::Migration
  def change
    add_column :exam_sittings, :active, :boolean, default: true
  end
end
