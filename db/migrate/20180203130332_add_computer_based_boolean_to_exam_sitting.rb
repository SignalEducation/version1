class AddComputerBasedBooleanToExamSitting < ActiveRecord::Migration[4.2]
  def change
    add_column :exam_sittings, :computer_based, :boolean, default: false, index: true
  end
end
